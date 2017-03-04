SELECT
       event_time AS [Time],
       server_principal_name AS [User],
       object_name AS [Object name],
       Statement
  FROM sys.fn_get_audit_file('c:\audits\ServerAudit*', NULL, NULL)
WHERE
       database_name
       =
       'ACMEDB'
   AND (
       Statement LIKE '%DISABLE%TRIGGER%'
    OR Statement LIKE '%ENABLE%TRIGGER%')ORDER BY
                                          [Time] DESC;