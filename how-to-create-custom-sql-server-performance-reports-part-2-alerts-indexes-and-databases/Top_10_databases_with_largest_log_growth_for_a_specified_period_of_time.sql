declare @StartDate datetimeoffset(7); 
declare @EndDate  datetimeoffset(7);
declare @MetricId uniqueidentifier;
declare @ServerId  uniqueidentifier;

set @StartDate  = '2016-12-01 06:00:00.0000000 +01:00'-- Enter the report start date/time
set @EndDate = '2016-12-30 06:00:00.0000000 +01:00' -- Enter the report end date/time
set @ServerId = ApexSQL.SourceNameToId ('.')  -- Enter SQL Server name
set @MetricId = ApexSQL.MetricNameToId('Log Growths')
	  
	  SELECT Top 10 ApexSQL.SourceIdToName (r.SourceId) as [Database], R.Y as [Log growths] FROM
	  (
	  SELECT SourceId, SUM (Value) as Y
      FROM   [ApexSQL].[MonitorMeasuredValues]
      WHERE MeasuredAt >= @StartDate AND MeasuredAt <= @EndDate  AND  
			MeasurementId = @MetricId AND    
			SourceId in (SELECT * FROM ApexSQL.GetAllSourcesSQLServer (@ServerId))
      GROUP BY SourceId
	  ) as R
	  ORDER by R.Y DESC
GO