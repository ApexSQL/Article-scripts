-- Stop connection monitor
IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor_Stop'
		)
	EXEC master.dbo.xp_ApexSqlConnectionMonitor_Stop

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor2008_Stop'
		)
	EXEC master.dbo.xp_ApexSqlConnectionMonitor2008_Stop

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2008ConnectionMonitor_Stop'
		)
	EXEC master.dbo.xp_ApexSqlLog2008ConnectionMonitor_Stop

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2010ConnectionMonitor_Stop'
		)
	EXEC master.dbo.xp_ApexSqlLog2010ConnectionMonitor_Stop

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogConnectionMonitor_Stop'
		)
	EXEC master.dbo.xp_ApexSqlLogConnectionMonitor_Stop

-- Drop connection monitor xprocs
-- 2005
IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor_Disable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor_Disable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor_Enable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor_Enable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor_Info'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor_Info'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor_Stop'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor_Stop'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlConnectionMonitor_Start'
		)
	EXEC master.dbo.sp_procoption 'sp_ApexSqlConnectionMonitor_Start'
		,'startup'
		,'false'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlConnectionMonitor_Start'
		)
	EXEC master.dbo.sp_executesql N'DROP PROCEDURE sp_ApexSqlConnectionMonitor_Start'

-- 2008
IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor2008'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor2008'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor2008_Stop'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor2008_Stop'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor2008_Info'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor2008_Info'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor2008_Enable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor2008_Enable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlConnectionMonitor2008_Disable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlConnectionMonitor2008_Disable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlConnectionMonitor2008_Start'
		)
	EXEC master.dbo.sp_procoption 'sp_ApexSqlConnectionMonitor2008_Start'
		,'startup'
		,'false'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlConnectionMonitor2008_Start'
		)
	EXEC master.dbo.sp_executesql N'DROP PROCEDURE sp_ApexSqlConnectionMonitor2008_Start'

-- 2008.05
IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2008ConnectionMonitor'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2008ConnectionMonitor'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2008ConnectionMonitor_Stop'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2008ConnectionMonitor_Stop'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2008ConnectionMonitor_Info'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2008ConnectionMonitor_Info'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2008ConnectionMonitor_Enable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2008ConnectionMonitor_Enable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2008ConnectionMonitor_Disable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2008ConnectionMonitor_Disable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2008ConnectionMonitor_State'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2008ConnectionMonitor_State'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlLog2008ConnectionMonitor_Start'
		)
	EXEC master.dbo.sp_procoption 'sp_ApexSqlLog2008ConnectionMonitor_Start'
		,'startup'
		,'false'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlLog2008ConnectionMonitor_Start'
		)
	EXEC master.dbo.sp_executesql N'DROP PROCEDURE sp_ApexSqlLog2008ConnectionMonitor_Start'

-- 2010
IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2010ConnectionMonitor'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2010ConnectionMonitor'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2010ConnectionMonitor_Stop'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2010ConnectionMonitor_Stop'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2010ConnectionMonitor_Info'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2010ConnectionMonitor_Info'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2010ConnectionMonitor_Enable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2010ConnectionMonitor_Enable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2010ConnectionMonitor_Disable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2010ConnectionMonitor_Disable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2010ConnectionMonitor_State'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2010ConnectionMonitor_State'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlLog2010ConnectionMonitor_Start'
		)
	EXEC master.dbo.sp_procoption 'sp_ApexSqlLog2010ConnectionMonitor_Start'
		,'startup'
		,'false'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlLog2010ConnectionMonitor_Start'
		)
	EXEC master.dbo.sp_executesql N'DROP PROCEDURE sp_ApexSqlLog2010ConnectionMonitor_Start'

-- 2011
IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogConnectionMonitor'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLogConnectionMonitor'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogConnectionMonitor_Stop'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLogConnectionMonitor_Stop'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogConnectionMonitor_Info'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLogConnectionMonitor_Info'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogConnectionMonitor_Enable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLogConnectionMonitor_Enable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogConnectionMonitor_Disable'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLogConnectionMonitor_Disable'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogConnectionMonitor_State'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLogConnectionMonitor_State'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlLogConnectionMonitor_Start'
		)
	EXEC master.dbo.sp_procoption 'sp_ApexSqlLogConnectionMonitor_Start'
		,'startup'
		,'false'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'sp_ApexSqlLogConnectionMonitor_Start'
		)
	EXEC master.dbo.sp_executesql N'DROP PROCEDURE sp_ApexSqlLogConnectionMonitor_Start'

-- Drop Log xprocs
IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2008'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2008'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog2010'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog2010'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLog'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLog'

-- Drop Log API xprocs
IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogApi2008'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLogApi2008'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogApi2010'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLogApi2010'

IF EXISTS (
		SELECT *
		FROM master.dbo.sysobjects
		WHERE NAME = 'xp_ApexSqlLogApi'
		)
	EXEC master.dbo.sp_dropextendedproc 'xp_ApexSqlLogApi'

-- Free xprocs
DBCC ApexSqlServerXprocs(FREE)

DBCC ApexSqlLog2008Xprocs(FREE)

DBCC ApexSqlLog2010Xprocs(FREE)

DBCC ApexSqlLogXprocs(FREE)