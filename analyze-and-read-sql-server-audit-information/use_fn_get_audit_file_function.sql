SELECT event_time
	,action_id
	,session_server_principal_name AS UserName
	,server_instance_name
	,database_name
	,schema_name
	,object_name
	,statement
FROM sys.fn_get_audit_file('D:\TestAudits\*.sqlaudit', DEFAULT, DEFAULT)
WHERE action_id IN ( 'SL', 'IN', 'DR', 'LGIF' , '%AU%' )