#Execute system stored procedure sp_replmonitorhelppublication, against the distribution database
#Extract the whole set of results into temp1.txt file
Invoke-Sqlcmd -Query "USE distribution
EXEC sp_replmonitorhelppublication" -ServerInstance "TIKVICKI" | Out-File d:\temp1.txt

#Filtering string which contains information on replication agents' status, and bridge it to another temporary file, temp2.txt
Get-Content d:\temp1.txt | where { $_.Contains("status                   : ") } | 
out-file d:\temp2.txt

#Modify and normalize previously mentioned string
#Rename the file into Replication_Agents_Status and append the timestamp (moment of the execution)
(Get-Content d:\temp2.txt).replace('status                   ', 'Replication agents status') | 
Set-Content d:\Replication_Agents_Status_$(get-date -f yyyy-MM-dd-hh-mm-ss).txt

#Remove temporary files
Remove-Item d:\temp1.txt -Force
Remove-Item d:\temp2.txt -Force