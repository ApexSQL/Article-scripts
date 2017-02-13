-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
declare @StartDate datetimeoffset(7);
declare @EndDate  datetimeoffset(7);

declare @SourceId uniqueidentifier;

declare @State  int;
declare @Severity  int;

set @StartDate  = '2016-11-1 06:00:00.0000000 +01:00'
set @EndDate = '2017-1-14 06:00:00.0000000 +01:00'

set  @SourceId = [ApexSQL].[SourceNameToId] ('SERVER2012R2-L1')  -- Enter SQL Server name
set  @State  = [ApexSQL].[AlertStateToNumberConverter] ('All')  -- Enter Alert state that should be displayed in report (Not fixed, Fixed, Ignored, Known issue and All). When 'All' is entered, alert with all states will be displayed
set  @Severity  = [ApexSQL].[AlertSeverityToNumberConverter] ('All') -- Enter Alert state that should be displayed in report (High, Medium, Low and All). When 'All' is entered, alert with all severities will be displayed

 
 -- Return detail information of alerts raised in the specified time period
---------------------------------------------------------------------
   SELECT 
		  ApexSQL.SourceIdToName(A.[SourceId]) as Source,
		  ApexSQL.MetricIdToName(A.[MeasurementId]) as Metric,
		  ApexSQL.SeverityToStringConverter(A.[Severity]) as Severity,
          [ApexSQL].[AlertCheckToStringConverter](A.[Checked]) as Reviewed,
          [ApexSQL].[AlertStateToStringConverter](A.[State]) as [State],
		  A.[Comment],
          A.[TimeRaised],
          MM.Value,
          A.[TimeResolved],
          A.[UserResolved]
  FROM [ApexSQLMonitor].[ApexSQL].[MonitorAlerts] A 
  LEFT JOIN ApexSQL.MonitorMeasuredValues MM ON [MeasuredValueId] = MM.Id
  	WHERE A.TimeRaised > @StartDate AND A.TimeRaised < @EndDate AND (A.State = @State or @State=4) and (A.Severity = @Severity or @Severity=4) AND A.SourceId in (SELECT * from ApexSQL.GetAllSourcesForMachine (@SourceID))
  		ORDER by A.Severity desc, A.TimeRaised
