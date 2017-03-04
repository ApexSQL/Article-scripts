[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') <server_name>
$db = $s.Databases.item('<database_name>')
$db.status
if ($db.status -eq 'OFFLINE, AUTOCLOSED'){$db.SetOnline()}
else {Break}