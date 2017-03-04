SELECT
       event_time AS [Event time],
       session_server_principal_name AS [User name] ,
       server_instance_name AS [Server name],
       database_name AS [Database name],
       object_name AS [Audited object],
       statement AS [T-SQL statement]
  FROM sys.fn_get_audit_file('C:\AUDITs\AuditObjectUsage*.sqlaudit', DEFAULT, 
DEFAULT);