#existence check for Reports, Outputs, or Summaries folders, and if they don’t exist they will be created
function CheckAndCreateFolder
{
    param 
    (
        [string] $rootFolder, 
        [switch] $reports, 
        [switch] $outputs,
        [switch] $summaries
    )

    $location = $rootFolder

    #location will be set using the corresponding switch
    if ($reports -eq $true)
    {
        $location += "\Reports"
    }
    if ($outputs -eq $true)
    {
        $location += "\Outputs"
    }
    if ($summaries -eq $true)
    {
        $location += "\Summaries"
    }
    #create the folder if it doesn't exist and return its path
    if (-not (Test-Path $location))
    { 
        New-Item -Path $location -ItemType Directory -Force | Out-Null
    }
    return $location
}

#defining variable for the recognizing current path 
$currentPath = (Split-Path $SCRIPT:MyInvocation.MyCommand.Path)

#root folder of the system
$rootFolder = "$currentPath"

#installation location of ApexSQL Diff
$diffLocation = "C:\Program Files\ApexSQL\ApexSQL Diff\ApexSQLDiff.com"

$executionSummary = "$rootFolder\ExecutionSummary.txt"
Clear-Content -Path $executionSummary

#location of the txt file with server and database names
$serversDatabaseLocation = "$currentPath\servers_databases.txt"

foreach($line in [System.IO.File]::ReadAllLines($serversDatabaseLocation))
{

    #defining variables for source and destination servers and databases
    $server1   = ($line -split ",")[0]    
    $database1 = ($line -split ",")[1]
    $server2   = ($line -split ",")[2]    
    $database2 = ($line -split ",")[3]

    #defining variables for location of all output files
    $reportsLocation   = CheckAndCreateFolder $rootFolder -Reports
    $outputsLocation   = CheckAndCreateFolder $rootFolder -Outputs
    $summariesLocation = CheckAndCreateFolder $rootFolder -Summaries 

    #defining variables for date stamp and names for all output files
    $cleanServerName1   = ($server1 -replace "\\",".")
    $cleanServerName2   = ($server2 -replace "\\",".")
    $stamp             = (Get-Date -Format "MMddyyyy_HHMMss")

    $reportName   = "$cleanServerName2.$database2.SchemaReport_$stamp.html"
    $outputName   = "$cleanServerName2.$database2.SchemaLog_$stamp.txt"
    $summaryName  = "$cleanServerName2.$database2.SchemaSummary_$stamp.txt"

    #defining variable for ApexSQL Diff CLI switches
    $schemaSwitches = "/s1:""$server1"" /d1:""$database1"" /s2:""$server2"" /d2:""$database2"" /ot:html /hro:d e s t is /on:""$reportsLocation\$reportName"" /suo:""$summariesLocation\$summaryName"" /out:""$outputsLocation\$outputName"" /sync /f /v /rece"
    
    #initiation of the schema comparison and synchronization process     
    (Invoke-Expression ("& `"" + $diffLocation +"`" " +$schemaSwitches))
    $returnCode = $lastExitCode

        #differences in schema are detected
    if($returnCode -eq 0)
    {
        #synchronize databases and create a report
        "`r`nSchema differences are found and a report is created. Return code is: $lastExitCode" >> "$outputsLocation\$outputName"
    }
    elseif($returnCode -eq 102)
    {
        #the newly created report will be removed, as no differences are detected
        if(Test-Path "$reportsLocation\$reportName")
        { 
            Remove-Item -Path "$reportsLocation\$reportName" -Force:$true -Confirm:$true 
            Remove-Item -Path "$summariesLocation\$summaryName" -Force:$true -Confirm:$true
            Remove-Item -Path "$outputsLocation\$outputName" -Force:$true -Confirm:$true
        }
        "`r`nDifferences are not detected and the latest output files are deleted. Return code is: $lastExitCode" >> "$outputsLocation\$outputName"
    }
    #an error is encountered
    else   
    {
        "`r`nAn error is encountered. Return error code is: $lastExitCode" >> "$outputsLocation\$outputName"
        "Failed for server: $server2 database: $database2. Return error code is: $lastExitCode" >> $executionSummary
        #the output file will be opened, as an error is encountered         
    }
}
if ([System.IO.File]::ReadAllLines($executionSummary).Count -eq 0)
{
    "Synchronization was successful for all data sources or no differences were detected" > $executionSummary
}
Invoke-Item -Path $executionSummary