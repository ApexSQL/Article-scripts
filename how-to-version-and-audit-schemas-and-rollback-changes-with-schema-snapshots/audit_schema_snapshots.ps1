<#
.SYNOPSIS Find the file which has the highest value for the "date stamped" parameter.
Find all files whose name starts with [Server].[Database] and ends with .axsnp.
If such file is not found, then that means that there isn't any snapshot previousely created
.EXAMPLE
FindSnapshotByDate $snapshotsLocation $srvCleanName $database
#> 

#
function FindSnapshotByStamp($folder, $server, $database)
{
    $files = Get-ChildItem -Path $folder -Filter "$server.$database*.axsnp"
    if ($files.Length -eq 0)
    {
        return $null
    }   
    $mostRecentFile = $files | Sort-Object -Property "CreationTime" -Descending | Select-Object -First 1
    return $mostRecentFile.FullName
}


#checks for existence of Snapshots, Reports or Output folders, and creates it if it is not created
function CheckAndCreateFolder
{
    param 
    (
        [string] $rootFolder, 
        [switch] $snapshots, 
        [switch] $reports, 
        [switch] $outputs
    )

    $location = $rootFolder

    #set the location based on the used switch
    if ($snapshots -eq $true)
    {
        $location += "\Snapshots"
    }
    if ($reports -eq $true)
    {
        $location += "\Reports"
    }
    if ($outputs -eq $true)
    {
        $location += "\Outputs"
    }
    #create the folder if it doesn't exist and return its path
    if (-not (Test-Path $location))
    { 
        mkdir $location -Force:$true -Confirm:$false | Out-Null 
    }
    return $location
}

#defining variable for the recognizing current path 
$currentPath = (Split-Path $SCRIPT:MyInvocation.MyCommand.Path)

#root folder of the system
$rootFolder = "$currentPath"

#installation location of ApexSQL Diff
$diffLocation = "C:\Program Files\ApexSQL\ApexSQL Diff\ApexSQLDiff.com"

#location of the txt file with server and database names:
$serversDatabaseLocation = "$currentPath\servers_databases.txt"

foreach($line in [System.IO.File]::ReadAllLines($serversDatabaseLocation))
{

#defining all required variables

    $server   = ($line -split ",")[0]    
    $database = ($line -split ",")[1]
    
    $snapshotsLocation = CheckAndCreateFolder $rootFolder -Snapshots
    $reportsLocation   = CheckAndCreateFolder $rootFolder -Reports
    $outputsLocation   = CheckAndCreateFolder $rootFolder -Outputs

    $cleanServerName   = ($server -replace "\\","")
    $stamp             = (Get-Date -Format "MMddyyyy_HHMMss")
    $latestSnapshot    = FindSnapshotByStamp $snapshotsLocation $cleanServerName $database

    $snapshotName = "$cleanServerName.$database.Snapshot_$stamp.axsnp"
    $reportName   = "$cleanServerName.$database.Report_$stamp.html"
    $outputName   = "$cleanServerName.$database.Log_$stamp.txt"

    $exportSnapshotSwitches  = "/s1:""$server"" /d1:""$database"" /sn2:""$snapshotsLocation\$snapshotName"" /export /f /v"
    $compareSnapshotSwitches = "/s1:""$server"" /d1:""$database"" /sn2:""$latestSnapshot"" /ot:html /hro:d s t is /on:""$reportsLocation\$reportName"" /out:""$outputsLocation\$outputName"" /f /v /rece"
    $returnCode = $lastExitCode

    #create snapshot for the current state if no previous snapshot is found    
    if($latestSnapshot -eq $null)  
    {
        "`r`nSnapshot is not found in the '$snapshotsLocation' folder.`r`nInitial snapshot will be created automatically`r`n`r`n" >> "$outputsLocation\$outputName"
        #create a snapshot for the current state of a database 
        (Invoke-Expression ("& `"" + $diffLocation +"`" " +$exportSnapshotSwitches)) >> "$outputsLocation\$outputName"
        "`r`n`r`nInitial snapshot has been automatically created and named '$snapshotName'.`r`n`r`nReturn code is: $lastExitCode" >> "$outputsLocation\$outputName"
        exit
    } 

    #compare the database with latest snapshot and create a report
    (Invoke-Expression ("& ""$diffLocation"" $compareSnapshotSwitches"))
    $returnCode = $lastExitCode

    #differences are detected
    if($returnCode -eq 0)
    {
        #create snapshot of current database state
        (Invoke-Expression ("& `"" + $diffLocation +"`" " +$exportSnapshotSwitches)) >> "$outputsLocation\$outputName"
        "`r`nSchema changes are detected and a snapshot is created. Return code is: $lastExitCode" >> "$outputsLocation\$outputName"
    }
    else
    {
        #remove the newly created report, since no differences are detected
        if(Test-Path "$reportsLocation\$reportName")
        { Remove-Item -Path "$reportsLocation\$reportName" -Force:$true -Confirm:$true }
        "`r`nThere are no differences and latest report is deleted. Return code is: $lastExitCode" >> "$outputsLocation\$outputName"
    
        #an error occurred
        if($returnCode -ne 102)
        {
            "`r`nAn error is encountered. Return error code is: $lastExitCode" >> "$outputsLocation\$outputName"
            #open the output file as an error is encountered 
            Invoke-Item "$outputsLocation\$outputName"
        }
    }
}
