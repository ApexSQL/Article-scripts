#check for the existence of the Outputs folder
function CheckAndCreateFolder($rootFolder, [switch]$Outputs)
{
    $location = $rootFolder

    #setting up location 
    if($Outputs -eq $true)
    {
        $location += "\Outputs"
    }
   
    #if the folder doesn't exist it will be created
    if(-not (Test-Path $location))
    { mkdir $location -Force:$true -Confirm:$false | Out-Null }

    return $location
}

#root folder for the commit process
$rootFolder = "Commit"

#commit summaries location
$outLocation = CheckAndCreateFolder $rootFolder -Outputs 

#application’s location, defining date stamped variable, application’s parameters 
$appLocation   = "C:\Program Files\ApexSQL\ApexSQL Diff\ApexSQLDiff"
$datestamp = (Get-Date -Format "MMddyyyy_HHMMss") 
$appParams = "/pr:""C:\Users\NeMaNjA\Desktop\Commit.axds"" /out:""$outputsLoc\CommitOutput_$datestamp.txt"" /sync /v /f"  
$retCode = $LASTEXITCODE 


#initiate the schema commit process
(Invoke-Expression ("& `"" + $appLocation +"`" " +$appParams))

#schema changes are detected
if($returnCode -eq 0)
{
"`r`nApexSQL Diff return error code: $LASTEXITCODE - Schema changes were successfully synchronized" >> "$outLocation\CommitOutput_$dateStamp.txt"
}
else
{
    #there are no schema changes
    if($returnCode -eq 102)
    {
    "`r`nApexSQL Diff return error code: $LASTEXITCODE - There are no schema changes. Job aborted" >> "$outLocation\CommitOutput_$dateStamp.txt"
    }
    #an error is encountered
    else
    {
     "`r`nApexSQL Diff return error code: $LASTEXITCODE - An error was encountered" >> "$outLocation\CommitOutput_$dateStamp.txt"
	
    #output file is opened when an error is encountered
    Invoke-Item "$outLocation\CommitOutput_$datestamp.txt"
    }
}