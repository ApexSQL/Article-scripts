EXEC master.dbo.sp_configure 'allow updates', 1;
EXEC master.dbo.sp_configure 'show advanced options', 1;
EXEC master.dbo.sp_configure 'default trace enabled', 1;
RECONFIGURE WITH OVERRIDE;
EXEC master.dbo.sp_configure 'show advanced options', 0;
EXEC master.dbo.sp_configure 'allow updates', 0;
RECONFIGURE WITH OVERRIDE;