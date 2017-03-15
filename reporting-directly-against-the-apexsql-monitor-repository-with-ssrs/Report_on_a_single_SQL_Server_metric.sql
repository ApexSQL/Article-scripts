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

-- The main part of the script. Returns the X(Time), Y(Value) table for specific source and metric 
---------------------------------------------------------------------
SELECT X
	,Y
FROM [ApexSQL].[MeasuredValueLineChart](ApexSQL.SourceNameToId(@ServerName), ApexSQL.MetricNameToId('Lock requests/sec'), -- Replace ‘Lazy writes/sec’ with another SQL Server metric or use as parameter in application 
		@StartDate, @EndDate, 0)
ORDER BY X
GO