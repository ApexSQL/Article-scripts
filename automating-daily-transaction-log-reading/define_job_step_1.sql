DECLARE @Str VARCHAR(100) 
SET @Str = 'E:\Test\Batch.bat ' 
EXEC master.dbo.XP_CMDSHELL @Str