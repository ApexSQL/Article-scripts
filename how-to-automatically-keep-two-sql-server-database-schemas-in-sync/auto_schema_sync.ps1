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

#root folder for the schema sync process
$rootFolder = "SchemaSync"

#output files location 
$outsLoc = CheckAndCreateFolder $rootFolder -Outputs

#ApexSQL Diff location, date stamp variable is defined, along with tool’s parameters 
$diffLoc   = "ApexSQLDiff"
$stamp = (Get-Date -Format "MMddyyyy_HHMMss") 
$Params = "/pr:""MyProject.axds"" /out:""$outsLoc\SchemaOutput_$stamp.txt"" /sync /v /f /rece"
$returnCode = $LASTEXITCODE

 #initiate the comparison and commit process
(Invoke-Expression ("& `"" + $diffLoc +"`" " +$Params))

#schema changes are detected
if($returnCode -eq 0)
{
"`r`n $LASTEXITCODE - Schema changes were successfully synchronized" >> "$outsLoc\SchemaOutput_$dateStamp.txt"

}
else
{
    #there are no schema changes
    if($returnCode -eq 102)
    {
    "`r`n $LASTEXITCODE - There are no schema changes. Job aborted" >> "$outsLoc\SchemaOutput_$dateStamp.txt"
    }
    #an error is encountered
    else
    {
    "`r`n $LASTEXITCODE - An error is encountered" >> "$outsLoc\SchemaOutput_$dateStamp.txt"
	
    #output file is opened when an error is encountered
    Invoke-Item "$outsLoc\SchemaOutput_$stamp.txt"
    }

}