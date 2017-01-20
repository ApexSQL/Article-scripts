CREATE TRIGGER Audit_DDL
ON DATABASE
    FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
     DECLARE
        @event xml;
     SET
     @event = EVENTDATA();
     INSERT INTO Audit_DDL_Events
     VALUES
     (
     REPLACE(CONVERT(varchar(50),
     @event.query('data(/EVENT_INSTANCE/PostTime)')), 'T', ' ')
     ,
     CONVERT(varchar(150),
     @event.query('data(/EVENT_INSTANCE/LoginName)'))
     ,
     CONVERT(varchar(150),
     @event.query('data(/EVENT_INSTANCE/UserName)'))
     ,
     CONVERT(varchar(150),
     @event.query('data(/EVENT_INSTANCE/DatabaseName)'))
     ,
     CONVERT(varchar(150),
     @event.query('data(/EVENT_INSTANCE/SchemaName)'))
     ,
     CONVERT(varchar(150),
     @event.query('data(/EVENT_INSTANCE/ObjectName)'))
     ,
     CONVERT(varchar(150),
     @event.query('data(/EVENT_INSTANCE/ObjectType)'))
     ,
     CONVERT(varchar(max),
     @event.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)'))
     );