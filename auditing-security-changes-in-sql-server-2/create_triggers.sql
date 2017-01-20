CREATE TRIGGER DDL_AUDIT_Logins ON ALL SERVER
FOR ADD_SERVER_ROLE_MEMBER
	,DDL_GDR_SERVER_EVENTS
	,DROP_SERVER_ROLE_MEMBER AS

SET NOCOUNT ON;

DECLARE @EventsTable TABLE (
	EType NVARCHAR(max)
	,EObject VARCHAR(100)
	,EDate DATETIME
	,EUser VARCHAR(100)
	,ECommand NVARCHAR(max)
	);
DECLARE @EType NVARCHAR(max);
DECLARE @ESchema NVARCHAR(max);
DECLARE @DBName VARCHAR(100);
DECLARE @Subject VARCHAR(200);
DECLARE @EObject VARCHAR(100);
DECLARE @EObjectType VARCHAR(100);
DECLARE @EMessage NVARCHAR(max);
DECLARE @ETSQL NVARCHAR(max);

SELECT @EType = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]',
 'nvarchar(max)')
,@ESchema = EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]',
 'nvarchar(max)')
,@EObject = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]',
 'nvarchar(max)')
,@EObjectType = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]',
'nvarchar(max)')
,@DBName = EVENTDATA().value('
(/EVENT_INSTANCE/DatabaseName)[1]',
 'nvarchar(max)')
,@ETSQL = EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 
'nvarchar(max)');

INSERT INTO @EventsTable
SELECT @EType
	,@EObject
	,GETDATE()
	,SUSER_SNAME()
	,@ETSQL;

SET @EMessage = 'Login_Event: ' + @EType + CHAR(10) + 'Event Occured at: '
 + Convert(VARCHAR, GETDATE()) + CHAR(10) + 'Changed Login: ' + @EObject + 
CHAR(10) + 'Changed by: ' + SUSER_SNAME() + CHAR(10) + 'Executed T-SQL: ' + 
@ETSQL

SELECT @Subject = 'SQL Server Login changed on ' + @@servername;

EXEC msdb.dbo.sp_send_dbmail @recipients = 'DDL_Alert@companydomain.com'
	,@body = @EMessage
	,@subject = @Subject
	,@body_format = 'HTML';

SET NOCOUNT OFF;
GO