CREATE TRIGGER DDL_Audit
ON DATABASE
    FOR ALTER_TABLE
AS
     DECLARE
        @auditevent xml;
     SET
     @auditevent = EVENTDATA();
     INSERT INTO DDL_Audit_Events
     VALUES
     (
     REPLACE(CONVERT(varchar(50),
     @auditevent.query('data(/EVENT_INSTANCE/PostTime)')), 'T', ' ')
     ,
     CONVERT(varchar(150),
     @auditevent.query('data(/EVENT_INSTANCE/LoginName)'))
     ,
     CONVERT(varchar(150),
     @auditevent.query('data(/EVENT_INSTANCE/DatabaseName)'))
     ,
     CONVERT(varchar(150),
     @auditevent.query('data(/EVENT_INSTANCE/ObjectName)'))
     ,
     CONVERT(varchar(max),
     @auditevent.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)'))
     );