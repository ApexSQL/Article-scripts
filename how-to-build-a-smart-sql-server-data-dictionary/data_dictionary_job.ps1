#find the Snapshot file which has the highest value for the "created date" parameter
function FindSnapshotByDate($folder)
{
    #find all files whose name ends with .axsnp
    $Files = Get-ChildItem -Path $folder -Filter "*.axsnp"
    if ($Files.Length -eq 0)
    {
        #if no such file is found, then that means that there isn't any snapshot previously created
        return $null
    }
    
    $mostRecentFile = $Files | Sort-Object -Property "CreationTime" -Descending | Select-Object -First 1
    return $mostRecentFile.FullName
}

#check the existance of Exports, Logs or Snapshot folders, creates it if it is not created and returns the path
function CheckAndCreateFolder($rootFolder, [switch]$Exports, [switch]$Baselines, [switch]$Logs)
{
    $location = $rootFolder

    #set the location based on the used switch
    if($Exports -eq $true)
    {
        $location += "\Exports"
    }
    if($Baselines -eq $true)
    {
        $location += "\Baselines"
    }
    if($Logs -eq $true)
    {
        $location += "\Logs"
    }
    
    #create the folder if it doesn't exist and return its path
    if(-not (Test-Path $location))
    { mkdir $location -Force:$true -Confirm:$false | Out-Null }

    return $location
}

#insert schema difference records into the datadictionary table
function InsertRecordsToDataDictionaryDatabase($dataDictionaryServer, $dataDictionaryDbName, $xmlExportFullPath)
{
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
   
    $SqlConnection.ConnectionString = "Server=$dataDictionaryServer;Initial catalog=$dataDictionaryDbName;Trusted_Connection=True;"

    try
    {
       $SqlConnection.Open()
       $SqlCommand = $SqlConnection.CreateCommand()
       $SqlCommand.CommandText = "EXEC [dbo].[FillDataDictionary] '$xmlExportFullPath'"

       $SqlCommand.ExecuteNonQuery() | out-null
    }
    catch
    {
        Write-Host "FillDataDictionary could not be executed`r`nException: $_"
    }
}

#################################################################################                                        

#read and parse config.xml file from root folder
[xml]$configFile = Get-Content config.xml

$server               = $configFile.config.Server
$database             = $configFile.config.Database
$dataDictionaryServer = $configFile.config.DataDictionaryServer
$dataDictionaryDbName = $configFile.config.DataDictionaryDatabaseName
$rootFolder           = $PSScriptRoot

#check if ApexSQLDiff is installed
$DiffInstallPath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ApexSQL Diff*" -Name "InstallLocation"
if(-not $DiffInstallPath)
{
    #ApexSQL Diff installation not found. Please install ApexSQL Diff to continue
}

$diffLocation      = $DiffInstallPath + "ApexSQLDiff.com"
  
$snapshotsLocation = CheckAndCreateFolder $rootFolder -Baselines
$exportLocation    = CheckAndCreateFolder $rootFolder -Exports
$logLocation       = CheckAndCreateFolder $rootFolder -Logs

$today          = (Get-Date -Format "MMddyyyy")
$latestSnapshot = FindSnapshotByDate $snapshotsLocation

$snapshotName = "SchemaSnapshot_$today.axsnp"
$logName      = "SnapshotLog_$today.txt"
$xml          = "SchemaDifferenceExport_$today.xml"

$initialCompare          = "/s1:""$server"" /d1:""$database"" /s2:""$server"" /d2:""$database"" /ot:x /xeo:e is /on:""$exportLocation\$xml"" /f /v"
$compareSettingsSnapshot = "/s1:""$server"" /d1:""$database"" /sn2:""$latestSnapshot"" /out:""$logLocation\$logName"" /rece /f /v"
$exportSettingsSnapshot  = "/s1:""$server"" /d1:""$database"" /sn2:""$snapshotsLocation\$snapshotName"" /export /f /v"
$diffExportXMLparams     = "/s1:""$server"" /d1:""$database"" /sn2:""$latestSnapshot"" /ot:x /xeo:d s t is /on:""$exportLocation\$xml"" /f /v" 

#if no previous snapshot found, create snapshot for current state and skip the rest
if($latestSnapshot -eq $null)  
{
     #put initial state of current database in datadictionary
     (Invoke-Expression ("& `"" + $diffLocation +"`" " +$initialCompare))
     InsertRecordsToDataDictionaryDatabase $dataDictionaryServer $dataDictionaryDbName $exportLocation\$xml

     #create snapshot of current database state
     (Invoke-Expression ("& `"" + $diffLocation +"`" " +$exportSettingsSnapshot))

     Write-Host "Snapshot is not found in the '$snapshotsLocation' folder.`r`n`r`nInitial snapshot has been automatically created and named '$snapshotName'"
     
     #here, add the comparison against empty datasource
     continue
}

 #compare the database with latest snapshot
 (Invoke-Expression ("& ""$diffLocation"" $compareSettingsSnapshot"))
 $returnCode = $LASTEXITCODE

 #differences detected
 if($returnCode -eq 0)
 {
    #Export differences into XML file
    (Invoke-Expression ("& ""$diffLocation"" $diffExportXMLparams"))
    #Add timestamp on each line of log file
    $tsOutput | ForEach-Object { ((Get-Date -format "MM/dd/yyyy hh:mm:ss") + ":  $_") >> $file }
 
    InsertRecordsToDataDictionaryDatabase $dataDictionaryServer $dataDictionaryDbName $exportLocation\$xml 
    
    #create snapshot of current database state
    (Invoke-Expression ("& `"" + $diffLocation +"`" " +$exportSettingsSnapshot))
 }
 #there are no differences or an error occurred
 else
 {
     #an error occurred
     if($returnCode -ne 102)
     {
         Write-Host "An error occurred during the application execution.`r`nError code: $returnCode"
         continue
     }
 } 
