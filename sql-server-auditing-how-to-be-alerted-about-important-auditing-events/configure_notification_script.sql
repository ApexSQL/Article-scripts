DECLARE @TempTime datetime2;
DECLARE @Counter int;
DECLARE @MailQuery NVARCHAR(MAX);
SET @Counter = 0
SET @TempTime = (SELECT TOP 1 LastEventTime FROM dbo.TempAuditTime)
SET @Counter= (SELECT COUNT (event_time) 
 FROM sys.fn_get_audit_file('C:\SqlAudits\*.sqlaudit', default, default)
 WHERE DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), event_time ) > @TempTime)
 PRINT @Counter
 IF @Counter > 0 

 	BEGIN
	SET @MailQuery = CAST ((SELECT td = DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), event_time), '', 
							td =statement, ''
					FROM sys.fn_get_audit_file('C:\SqlAudits\*.sqlaudit', default, default)
					WHERE DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), event_time ) > @TempTime FOR XML PATH('tr'), TYPE
					) AS NVARCHAR(MAX))

DECLARE @tableHTML  NVARCHAR(MAX) ;

SET @tableHTML =
    N'<H1>Security Event Report</H1>' +
    N'<table border="1">' +
    N'<tr><th>Event time</th><th>Statement</th>'+
	N'</tr>' +
    @MailQuery +
    N'</table>';
	
 PRINT @tableHTML

 -- Update temp table event time
USE master

	UPDATE dbo.TempAuditTime
   SET [LastEventTime] = SYSDATETIME ()

-- Send Email
EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'SecurityEvent', 
		@recipients = 'nikola.dimitrijevic@apexsql.com',
		@body = @tableHTML,
		@body_format = 'HTML',
		@subject = 'Security Event Occured';
		
    	END; 