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

#checks the existance of Reports or Logs folders, creates it if it is not created and returns the path
function CheckAndCreateFoder($rootFolder, [switch]$Reports, [switch]$Logs)
{
    $location = $rootFolder

    #set the location based on the used switch
    if($Reports -eq $true)
    {
        $location += "\Reports"
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

$scType = "git"
$scUser = "UserName"
$scPass = "PaSSw0d"
$scRepo = "https://UserName@bitbucket.org/UserName/reponame.git"
$scProj = "$/ProjectName"
#endregion

foreach($line in [System.IO.File]::ReadAllLines($databasesTxtPath))
{
#region Non-editable variables

    $server   = ($line -split ",")[0]    
    $database = ($line -split ",")[1]
    
    $reportLocation    = CheckAndCreateFoder $rootFolder -Reports
    $logLocation       = CheckAndCreateFoder $rootFolder -Logs

    $srvCleanName   = ($server -replace "\\","")
    $today          = (Get-Date -Format "MMddyyyy")

    $reportName   = "$srvCleanName.$database.Report_$today.html"
    $logName      = "$srvCleanName.$database.SCLog_$today.txt"

    $compareSettings = "/s1:""$server"" /d1:""$database"" /sct2:$scType /scu2:""$scUser"" /scp2:""$scPass"" /scr2:""$scRepo"" /scj2:""$scProj"" /v /f /ot:html /hro:d s t is /on:""$reportLocation\$reportName"" /out:""$logLocation\$logName"""  
    $syncSettings    = "/s1:""$server"" /d1:""$database"" /sct2:$scType /scu2:""$scUser"" /scp2:""$scPass"" /scr2:""$scRepo"" /scj2:""$scProj"" /v /f /scsc:$today /scsl:""Label_$today"" /sync"    
  
#endregion

    #compare database with source control and create a comparison report
    (Invoke-Expression ("& ""$diffLocation"" $compareSettings"))
    $returnCode = $LASTEXITCODE

    #differences detected
    if($returnCode -eq 0)
    {
        $text = "Differences are detected.`r`nPlease check attached report file"
        $attach = "$reportLocation\$reportName"

        SendMail -subject "TEST subject" -text $text -attachment "$attach"

        #sync with source control
        (Invoke-Expression ("& `"" + $diffLocation +"`" " +$syncSettings))
    }
    #there are no differences or an error occurred
    else
    {
        #remove the newly created report, since no differences are detected
        if(Test-Path "$reportLocation\$reportName")
        {
            Remove-Item -Path "$reportLocation\$reportName" -Force:$true -Confirm:$false
        }

        #something happened
        if($returnCode -ne 103)
        {
            $text = "An issue occurred during the application execution.`r`nPlease check the attached log file"
            $attach = $LogPath
        }

        SendMail -subject "TEST subject" -text $text -attachment "$attach"
    }
}
