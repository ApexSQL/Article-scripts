IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlRecover2008'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlRecover2008'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlRecover'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlRecover'

DBCC ApexSqlRecover2008Xprocs(FREE)

DBCC ApexSqlRecoverXprocs(FREE)