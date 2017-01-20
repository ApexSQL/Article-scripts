SELECT event_time
	,session_server_principal_name AS Changed_by
	,target_server_principal_name AS LoginName
	,server_instance_name
	,statement
FROM sys.fn_get_audit_file('C:\AUDITs\*.sqlaudit', DEFAULT, DEFAULT)
WHERE action_id = 'G'
	OR action_id = 'APRL';