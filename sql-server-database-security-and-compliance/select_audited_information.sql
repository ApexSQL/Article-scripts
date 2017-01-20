SELECT
       event_time ,
       session_server_principal_name AS UserName ,
       server_instance_name AS ServerName,
       database_name ,
       object_name ,
       statement
  FROM sys.fn_get_audit_file('C:\AUDITs\AuditDatabaseUsers*.sqlaudit',
DEFAULT, DEFAULT);