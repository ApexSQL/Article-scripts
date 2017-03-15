USE ApexSQLMonitor
GO

-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
DECLARE @StartDate DATETIMEOFFSET(7);
DECLARE @EndDate DATETIMEOFFSET(7);
DECLARE @ServerName NVARCHAR(256);
DECLARE @MachineName NVARCHAR(256);

SET @StartDate = '2016-11-01 00:00:00.0000000 +01:00' -- Enter the report start date/time
SET @EndDate = '2016-12-01 00:00:00.0000000 +01:00' -- Enter the report end date/time
SET @MachineName = '<machine name>' -- Enter machine/computer name

-- This is the main part of the script that returns the X(Status), Y(Value) table.
-- It is useful for status metrics with two states e.g. system availability status 
---------------------------------------------------------------------
SELECT ApexSQL.StatusConverter(X) AS STATUS
	,Y
FROM [ApexSQL].[MeasuredValuePieChart](ApexSQL.SourceNameToId(@MachineName), ApexSQL.MetricNameToId('System availability'), @StartDate, @EndDate)
GO