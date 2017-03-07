function SendMail($subject, $text, $attachment)
{

    $SecurePassword = "PaSSw0rd" | ConvertTo-SecureString -AsPlainText -Force
    $from = "fromnoname@gmail.com"
    $to = "tononame@gmail.com"
    $Credentials = New-Object System.Management.Automation.PSCredential ("fromnoname", $SecurePassword)
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
            return ("Sending e-mail failed: " + $_.Exception + "`r`n")
            #or return $false
        }
}

#checks for existence of Reports or Logs folders, and creates it if it is not created
function CheckAndCreateFolder
{
    param 
    (
        [string] $rootFolder, 
        [switch] $reports, 
        [switch] $logs
    )

    $location = $rootFolder

    #set the location based on the used switch
    if ($reports -eq $true)
    {
        $location += "\Reports"
    }
    if ($logs -eq $true)
    {
        $location += "\Logs"
    }
    #create the folder if it doesn't exist and return its path
    if (-not (Test-Path $location))
    { 
        mkdir $location -Force:$true -Confirm:$false | Out-Null 
    }
    return $location
}

#root folder for the schema sync process
$rootFolder = "SchemaSync"

#output files location 
$reportsLocation = CheckAndCreateFolder $rootFolder -Reports
$logsLocation    = CheckAndCreateFolder $rootFolder -Logs

#ApexSQL Diff location, date stamp variable is defined, along with tool’s parameters 
$diffLocation  = "ApexSQLDiff"
$dateStamp = (Get-Date -Format "MMddyyyy_HHMMss") 
$diffSwitches = "/pr:""SchemaSync.axds"" /ot:html /hro:d s t is /on:""$reportsLocation\SchemaReport_$dateStamp.html"" /out:""$logsLocation\SchemaLog_$dateStamp.txt"" /sync /v /f /rece"

#initiate the comparison and synchronization process
(Invoke-Expression ("& `"" + $diffLocation +"`" " +$diffSwitches))
$returnCode = $lastExitCode

#differences detected
if($returnCode -eq 0)
{
    $text = "Differences are detected.`r`nPlease check attached report file"
    $attach = "$reportsLocation\SchemaReport_$dateStamp.html"

    SendMail -subject "ApexSQL Diff synchronization results" -text $text -attachment "$attach"
    "`r`nThere are differences and HTML report is created. Return code: $returnCode" >> "$logsLocation\SchemaLog_$dateStamp.txt"
    exit
}

#there are no differences or an error occurred
else
{
    #remove the newly created report, since no differences are detected
    if(Test-Path "$reportsLocation\SchemaReport_$dateStamp.html")
    { 
        Remove-Item -Path "$reportsLocation\SchemaReport_$dateStamp.html" -Force:$true -Confirm:$false 
    }
    "`r`nThere are no differences and latest report is deleted. Return code: $returnCode" >> "$logsLocation\SchemaLog_$dateStamp.txt"

    #an error occurred
    if($returnCode -ne 102)
    {
        "`r`nAn issue occurred during the application execution at $dateStamp.`r`nReturn code: $returnCode`r`n" >> "$logsLocation\SchemaLog_$dateStamp.txt"
        $text = "An issue occurred during the application execution at $dateStamp.`r`nPlease see the attached log file for details"
        $attach = "$logsLocation\SchemaLog_$dateStamp.txt"
        
        SendMail -subject "ApexSQL Diff synchronization error" -text $text -attachment "$attach"  
    }    
}