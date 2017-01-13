#check if ApexSQLDiff is installed
$DiffInstallPath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ApexSQL Diff*" -Name "InstallLocation"
if(-not $DiffInstallPath)
{
    #ApexSQL Diff is not installed
    Write-Output "ApexSQL Diff installation not found. Install ApexSQL Diff to continue"
    exit
}
$diffLocation = $DiffInstallPath + "ApexSQLDiff.com"

#create timestamp variable for the log file
$today = (Get-Date -Format "MMddyyyy_HHmmss")

#build ApexSQL Diff compare parameters
$projectFile = $PSScriptRoot + "\" + "Compare.axds"
$outputLog = $PSScriptRoot + "\" + "CompareLog_$today.log" 
$exportXML = $PSScriptRoot + "\" + "SchemaDifference.xml" 
$compareParameters = "/pr:""$projectFile"" /rece /f /v /ot:x /xeo:d s t is /on:""$exportXML"" /out:""$outputLog""" 
 
#compare the database with repository
(Invoke-Expression ("& ""$diffLocation"" $compareParameters"))

$returnCode = $LASTEXITCODE

#differences detected
if($returnCode -eq 0)
{
    Write-Output "Differences detected, call the next script.`r`nError code: $returnCode"
    #trigger next script
}
#there are no differences or an error occurred
else
{
    #no differences detected
    if($returnCode -eq 102)
    {
        Write-Output "No differences detected.`r`nError code: $returnCode"
        continue
    }
    #an error occurred
    if($returnCode -ne 102)
    {
        Write-Output "An error occurred during the application execution.`r`nError code: $returnCode"
        continue
    }
}