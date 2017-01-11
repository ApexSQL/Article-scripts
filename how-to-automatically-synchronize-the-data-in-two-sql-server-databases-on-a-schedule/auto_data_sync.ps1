#checks the existence of Outputs folder and creates it if it is not created and returns the path
function CheckAndCreateFolder($rootFolder, [switch]$Outputs)
{
    $location = $rootFolder

    #set the location based on the used switch
    if($Outputs -eq $true)
    {
        $location += "\Outputs"
    }
    #create the folder if it doesn't exist and return its path
    if(-not (Test-Path $location))
    { mkdir $location -Force:$true -Confirm:$false | Out-Null }

    return $location
} 

#root folder for the whole process
$rootFolder = "DataSync"

#location for the output files 
$outputsLocation   = CheckAndCreateFolder $rootFolder -Outputs 

#provide tool’s location, define date stamp variable, and tool’s parameters 
$toolLocation   = "ApexSQLDataDiff"
$dateStamp = (Get-Date -Format "MMddyyyy_HHMMss") 
$toolParameters = "/pr:""MyProject.axdd"" /out:""$outputsLocation\DataOutput_$dateStamp.txt"" /sync /v /f /rece" 

#initiate the comparison of data sources
(Invoke-Expression ("& `"" + $toolLocation +"`" " +$toolParameters))
$returnCode = $LASTEXITCODE 

#differences detected
if($returnCode -eq 0)
{
"`r`n $LASTEXITCODE - Changes were successfully synchronized" >> "$outputsLocation\DataOutput_$dateStamp.txt"


}
else
{
    #no changes were detected
    if($returnCode -ne 102)
    {
"`r`n $LASTEXITCODE - No changes were detected. Job aborted" >> "$outputsLocation\DataOutput_$dateStamp.txt"

    }
    #an error occurred
    else
    {
    "`r`n $LASTEXITCODE - An error occurred" >> "$outputsLocation\DataOutput_$dateStamp.txt"
    
    #opens output file at the end of application execution on error
    Invoke-Item "$outputsLocation\DataOutput_$stamp.txt"
    }

}  
