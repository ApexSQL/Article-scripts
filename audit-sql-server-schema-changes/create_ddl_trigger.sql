CREATE TRIGGER Audit_Table_DDL
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
DECLARE       @eventInfo XML
SET           @eventInfo = EVENTDATA()
 
INSERT INTO Audit_Info VALUES
(
     REPLACE(CONVERT(VARCHAR(50),
            @eventInfo.query('data(/EVENT_INSTANCE/PostTime)')),'T', ' '),
     CONVERT(VARCHAR(255),
          @eventInfo.query('data(/EVENT_INSTANCE/LoginName)')),
     CONVERT(VARCHAR(255),
          @eventInfo.query('data(/EVENT_INSTANCE/UserName)')),
     CONVERT(VARCHAR(255),
          @eventInfo.query('data(/EVENT_INSTANCE/HostName)')),
     CONVERT(VARCHAR(255),
          @eventInfo.query('data(/EVENT_INSTANCE/ApplicationName)')),
     CONVERT(VARCHAR(255),
          @eventInfo.query('data(/EVENT_INSTANCE/DatabaseName)')),
     CONVERT(VARCHAR(255),
          @eventInfo.query('data(/EVENT_INSTANCE/SchemaName)')),
     CONVERT(VARCHAR(255),
          @eventInfo.query('data(/EVENT_INSTANCE/ObjectName)')),
     CONVERT(VARCHAR(255),
          @eventInfo.query('data(/EVENT_INSTANCE/ObjectType)')),
     CONVERT(VARCHAR(MAX),
          @eventInfo.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)'))
)