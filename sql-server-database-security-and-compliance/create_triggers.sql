CREATE TRIGGER DatabaseUserChange
ON DATABASE
    FOR CREATE_USER, ALTER_USER, DROP_USER
AS
     SET NOCOUNT ON;
     DECLARE
        @AuditTable TABLE (
                          AType nvarchar(max),
                          AObject varchar(100),
                          ADate datetime,
                          AWho varchar(100),
                          ACommand nvarchar(max)
        );
     DECLARE
        @AType nvarchar(max);
     DECLARE
        @AObject varchar(100);
     DECLARE
        @ATSQL nvarchar(max);
     SELECT
            @AType = EVENTDATA().value(
            '(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(max)')
            , @AObject = EVENTDATA().value(
            '(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(max)')
            , @ATSQL = EVENTDATA().value(
            '(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]',
            'nvarchar(max)');
      INSERT INTO @AuditTable
      SELECT
            @AType, @AObject, GETDATE(), SUSER_SNAME(), @ATSQL;
      SET NOCOUNT OFF;
GO