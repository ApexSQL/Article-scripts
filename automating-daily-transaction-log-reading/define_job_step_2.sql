DECLARE @SQLStatement VARCHAR(2000)
SET @SQLStatement = 'sqlcmd -S Fujitsu\SQL2012 -d AdventureWorks2012 -i 
E:\test\SQLBulk_' + CONVERT(nvarchar(30), GETDATE(), 110) +'.sql'
EXECUTE master.dbo.xp_cmdshell @SQLStatement