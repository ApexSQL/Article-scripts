-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
declare @StartDate datetimeoffset(7);
declare @EndDate  datetimeoffset(7);

declare @ServerName  nvarchar(256);
declare @MachineName  nvarchar(256);

declare @State  int;
declare @Severity  int;

set @StartDate  = '2016-11-1 06:00:00.0000000 +01:00'
set @EndDate = '2017-1-14 06:00:00.0000000 +01:00'

set  @MachineName = [ApexSQL].[SourceNameToId] ('SERVER2012R2-L1')  -- Enter Machine name

set  @Severity  = [ApexSQL].[AlertSeverityToNumberConverter] ('All') -- Enter Alert state that should be displayed in report (High, Medium, Low and All). When 'All' is entered, alert with all severities will be displayed 


-- Top 10 metrics with the highest number of SQL Server alerts 

SELECT TOP 10 * FROM
(
SELECT ApexSQL.MetricIdToName ([MeasurementId]) As MetricName
       ,COUNT(*) as [Alert number]
  FROM [ApexSQLMonitor].[ApexSQL].[MonitorAlerts]  
  WHERE SourceId in (SELECT * from ApexSQL.GetAllSourcesForMachine(@MachineName))
  AND (Severity = @Severity or @Severity=4)
AND @StartDate < TimeRaised AND @EndDate > TimeRaised
  GROUP BY [SourceId],[MeasurementId] 
) as R 
ORDER BY R.[Alert number] DESC