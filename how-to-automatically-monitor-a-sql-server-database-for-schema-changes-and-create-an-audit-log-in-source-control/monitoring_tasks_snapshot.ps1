#find the file which has the highest value for the "created date" parameter
function FindSnapshotByDate($folder, $server, $database)
{
    #find all files whose name starts with [Server].[Database] and ends with .axsnp
    $Files = Get-ChildItem -Path $folder -Filter "$server.$database*.axsnp"
    if ($Files.Length -eq 0)
    {
        #if no such file is found, then that means that there isn't any snapshot previousely created
        return $null
    }
    
    $mostRecentFile = $Files | Sort-Object -Property "CreationTime" -Descending | Select-Object -First 1
    return $mostRecentFile.FullName
}

function SendMail($subject, $text, $attachment)
{

    $SecurePassword = "PaSSw0d" | ConvertTo-SecureString -AsPlainText -Force
    $from = "fromnoname@gmail.com"
    $to = "tononame@gmail.com"
    $Credentials = New-Object System.Management.Automation.PSCredential ("fromnoname ", $SecurePassword)
    $smtpServer = 'smtp.gmail.com'

    $mailprops=@{
        Subject = $subject
        Body = $text
        To = $to
        From = $from
        SmtpServer = $smtpServer
        UseSsl = $true
        Port = 587
        Credential = $Credentials
    }

        try
        {
            if($attachment -ne $null)
            {
                Send-MailMessage @mailprops -ErrorAction:Stop -Attachments:$attachment
            }
            else
            {
                Send-MailMessage @mailprops -ErrorAction:Stop
            }
            return "Mail succesfully sent`r`n" 
            #or return $true
        }
        catch
        {
            return ("Send mail failed: " + $_.Exception + "`r`n")
            #or return $false
        }
    
}

#checks the existance of Reports, Logs or Baselines folders, creates it if it is not created and returns the path
function CheckAndCreateFoder($rootFolder, [switch]$Reports, [switch]$Baselines, [switch]$Logs)
{
    $location = $rootFolder

    #set the location based on the used switch
    if($Reports -eq $true)
    {
        $location += "\Reports"
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

#############################################################################################################
#                                         Starting point of script
#############################################################################################################

#region Editable variables
$rootFolder        = "C:\Monitor"
$databasesTxtPath  = "C:\Monitor\Databases.txt"

$diffLocation      = "C:\Program Files\ApexSQL\ApexSQL Diff\ApexSQLDiff.com"
#endregion

foreach($line in [System.IO.File]::ReadAllLines($databasesTxtPath))
{
#region Non-editable variables

    $server   = ($line -split ",")[0]    
    $database = ($line -split ",")[1]
    
    $snapshotsLocation = CheckAndCreateFoder $rootFolder -Baselines
    $reportLocation    = CheckAndCreateFoder $rootFolder -Reports
    $logLocation       = CheckAndCreateFoder $rootFolder -Logs

    $srvCleanName   = ($server -replace "\\","")
    $today          = (Get-Date -Format "MMddyyyy")
    $latestSnapshot = FindSnapshotByDate $snapshotsLocation $srvCleanName $database

    $snapshotName = "$srvCleanName.$database.SchemaSnapshot_$today.axsnp"
    $reportName   = "$srvCleanName.$database.Report_$today.html"
    $logName      = "$srvCleanName.$database.SnapshotLog_$today.txt"

    $compareSettingsSnapshot = "/s1:""$server"" /d1:""$database"" /sn2:""$latestSnapshot"" /ot:html /hro:d s t is /on:""$reportLocation\$reportName"" /out:""$logLocation\$logName"" /f /v"
    $exportSettingsSnapshot  = "/s1:""$server"" /d1:""$database"" /sn2:""$snapshotsLocation\$snapshotName"" /export /f /v"

    #if no previous snapshot found, create snapshot for current state and skip the rest
    if($latestSnapshot -eq $null)  
    {
        #create snapshot of current database state
        (Invoke-Expression ("& `"" + $diffLocation +"`" " +$exportSettingsSnapshot))

        $text = "Snapshot is not found in the '$snapshotsLocation' folder.`r`n`r`nInitial snapshot has been automatically created and named '$snapshotName'"

        SendMail -subject "TEST subject" -text $text -attachment $null
        continue
    }

    #compare the database with latest snapshot and create a report
    (Invoke-Expression ("& ""$diffLocation"" $compareSettingsSnapshot"))
    $returnCode = $LASTEXITCODE

    #differences detected
    if($returnCode -eq 0)
    {
        $text = "Differences are detected.`r`nPlease check attached report file '$reportName'"
        $attach = "$reportLocation\$reportName"
        
        #create snapshot of current database state
        (Invoke-Expression ("& `"" + $diffLocation +"`" " +$exportSettingsSnapshot))

        SendMail -subject "TEST subject" -text $text -attachment "$attach"
    }
    #there are no differences or an error occurred
    else
    {
        #remove the newly created report, since no differences are detected
        if(Test-Path "$reportLocation\$reportName")
        { Remove-Item -Path "$reportLocation\$reportName" -Force:$true -Confirm:$false }

        #an error occurred
        if($returnCode -ne 103)
        {
            $text = "An error occurred during the application execution.`r`nPlease check the attached log file"
            $attach = "$logLocation\$logName"
        }
        SendMail -subject "TEST subject" -text $text -attachment "$attach"
    }
}