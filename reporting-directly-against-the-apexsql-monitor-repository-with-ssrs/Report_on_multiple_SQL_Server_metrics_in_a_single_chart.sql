USE ApexSQLMonitor
GO

-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
DECLARE @StartDate DATETIMEOFFSET(7);
DECLARE @EndDate DATETIMEOFFSET(7);
DECLARE @ServerName NVARCHAR(256);
DECLARE @MachineName NVARCHAR(256);

SET @StartDate = '2016-12-18 06:00:00.0000000 +01:00' -- Enter the report start date/time
SET @EndDate = '2016-12-19 06:00:00.0000000 +01:00' -- Enter the report end date/time
SET @ServerName = '<SQL Server name>' -- Enter SQL Server name
SET @MachineName = '<machine name>' -- Enter machine/computer name

-- The main part of the script. Returns the X(Time), Y(Value), Serie(Metric name) for specific source and SQL Server metrics. Useful for multiline charts 
---------------------------------------------------------------------
SELECT X
	,Y
	,Serie
FROM [ApexSQL].[MeasuredValueMultiLineChart](ApexSQL.SourceNameToId(@ServerName), ApexSQL.MetricNameToId('Page writes/sec'), -- Enter first SQL Server metric name
		@StartDate, @EndDate, 0)

UNION ALL

SELECT X
	,Y
	,Serie
FROM [ApexSQL].[MeasuredValueMultiLineChart](ApexSQL.SourceNameToId(@ServerName), ApexSQL.MetricNameToId('Page reads/sec'), -- Enter Second SQL Server metric name
		@StartDate, @EndDate, 0)
GO