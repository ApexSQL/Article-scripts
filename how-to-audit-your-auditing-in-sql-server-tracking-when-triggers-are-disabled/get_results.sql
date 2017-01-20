SELECT
       DDL_Event_Time
       , DDL_Login_Name
       , DDL_Database_Name
       , DDL_Object_Name
       , DDL_Command
  FROM ACMEDB.dbo.DDL_Audit_Events WHERE
DDL_Command LIKE '%DISABLE%TRIGGER%'
OR DDL_Command LIKE '%ENABLE%TRIGGER%'
ORDER BY
         DDL_event_time DESC;