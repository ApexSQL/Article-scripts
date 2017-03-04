CREATE TRIGGER t_Pers 
ON Person.Person 
AFTER INSERT, UPDATE, DELETE 
AS 
   EXEC msdb.dbo.sp_send_dbmail 
                        @profile_name = 'ApexSQLProfile', 
                        @recipients = 'marko.radakovic@apexsql.com' , 
                        @body = 'Data in AdventureWorks2012 is changed', 
                        @subject = 'Your records have been changed' 
GO