#existence check and creating of Outputs and Reports folders
function CheckAndCreateFolder
{
    param 
    (
        [string] $rootFolder, 
        [switch] $reports, 
        [switch] $outputs
    )

    $location = $rootFolder

    #set the location based on the used switch
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

#root folder
$rootFolder = " \\vmware-host\Shared\AutoSF"

#location for HTML reports 
$repLocation = CheckAndCreateFolder $rootFolder -Reports

#location for schema output summaries 
$outLocation = CheckAndCreateFolder $rootFolder -Outputs

#location of ApexSQL Diff and text file with server and database names 
$diffLocation = "C:\Program Files\ApexSQL\ApexSQL Diff\ApexSQLDiff.com"
$serverDbsLocation = "servers_databases.txt" 

#application's parameters, along with the date stamped and return code variables:
$stampDate = (Get-Date -Format "MMddyyyy_HHMMss") 
$diffParameters = "/s:""$server"" /d:""$database"" /pr:""SFSync.axds"" /ots:m d /ot:html /hro:d s t is /on:""$repLocation\ReportSchema_$stampDate.html"" /out:""$outLocation\OutputSummary_$stampDate.txt"" /sync /v /f" 
$returnCode = $LASTEXITCODE

#go through each database and exeute ApexSQL Diff's parameters
foreach($line in [System.IO.File]::ReadAllLines($serverDbsLocation))
{

    $server   = ($line -split ",")[0]    
    $database = ($line -split ",")[1]

    #calling ApexSQL Diff to run the schema comparison and synchronization process
    (Invoke-Expression ("& `"" + $diffLocation +"`" " +$diffParameters))

    #differences in compared data sources were detected
    if($returnCode -eq 0)
    {
    "`r`nThere are differences and HTML report is created. Return code: $returnCode" >> "$outLocation\OutputSummary_$stampDate.txt"
    }
    #there are no differences or an error occurred
    else
    {
        #remove the newly created report, since no differences are detected
        if(Test-Path "$repLocation\ReportSchema_$stampDate.html")
        { 
            Remove-Item -Path "$repLocation\ReportSchema_$stampDate.html" -Force:$true -Confirm:$false 
        }
        "`r`nThere are no differences and latest report is deleted. Return code: $returnCode" >> "$outLocation\OutputSummary_$stampDate.txt"

        #an error occurred
        if($returnCode -ne 102)
        {
            "`r`nAn issue occurred during the application execution at $stampDate.`r`nReturn code: $returnCode`r`n" >> "$outLocation\OutputSummary_$stampDate.txt"
        }    
    }
}