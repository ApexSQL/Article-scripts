#check existence and create output folders
function FolderCheckAndCreate
{
    param 
    (
        [string] $rootPath, 
        [switch] $reps, 
        [switch] $outs
    )

    $path = $rootPath

    #the path is set based on the used switch
    if ($reps -eq $true)
    {
        $path += "\Reps"
    }
    if ($outs -eq $true)
    {
        $path += "\Outs"
    }
    #if folder doesn't exist, create it and return its path
    if (-not (Test-Path $path))
    { 
        mkdir $path -Force:$true -Confirm:$false | Out-Null 
    }
    return $path
}

#root folder path
$rootPath = "\\host-machine\SharedFolder\AutoDBtoSF\Dev1"

#path for HTML reports 
$repPath = FolderCheckAndCreate $rootPath -Reps

#path for schema output summaries 
$outPath = FolderCheckAndCreate $rootPath -Outs

#define paths for ApexSQL Diff and text file with database and server names 
$diffPath = " ApexSQLDiff"
$dbsServersPath = " databases_servers.txt"  

#define ApexSQL Diff CLI switches and variables for time/date stamp and return code
$timeDateStamp = (Get-Date -Format "MMddyyyy_HHMMss") 
$diffSwitches = "/s2:""$server"" /d2:""$database"" /pr:""SFtoDBSync.axds"" /ots:d m /ot:html /hro:s d is t /on:""$repPath\SchemaRep_$timeDateStamp.html"" /out:""$outPath\SumOut_$timeDateStamp.txt"" /sync /v /f" 
$returnCode = $LASTEXITCODE 

#go through each database and exeute ApexSQL Diff's parameters
foreach($line in [System.IO.File]::ReadAllLines($dbsServersPath))
{

    $server   = ($line -split ",")[0]    
    $database = ($line -split ",")[1]

    #calling ApexSQL Diff to run the schema comparison and synchronization process
    (Invoke-Expression ("& `"" + $diffPath +"`" " +$diffSwitches))

    #differences in compared data sources were detected
    if($returnCode -eq 0)
    {
    "`r`nThere are differences and HTML report is created. Return code: $returnCode" >> "$outPath\SumOut_$timeDateStamp.txt"
    }
    #there are no differences or an error occurred
    else
    {
        #remove the newly created report, since no differences are detected
        if(Test-Path "$repPath\SchemaRep_$stampDate.html")
        { 
            Remove-Item -Path "$repPath\SchemaRep_$timeDateStamp.html" -Force:$true -Confirm:$false 
        }
        "`r`nThere are no differences and latest report is deleted. Return code: $returnCode" >> "$outPath\SumOut_$timeDateStamp.txt"

        #an error occurred
        if($returnCode -ne 102)
        {
            "`r`nAn issue occurred during the application execution at $timeDateStamp.`r`nReturn code: $returnCode`r`n" >> "$outLocation\SumOut_$timeDateStamp.txt"
        }    
    }
}