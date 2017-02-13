USE ApexSQLMonitor
GO


--Returns line chart data X(Time),Y(Value)
CREATE FUNCTION [ApexSQL].[MeasuredValueLineChart]
(
	@SourceId uniqueidentifier, 
	@MeasurmentId  uniqueidentifier, 
	@StartDate DateTimeOffset, 
	@EndDate DateTimeOffset,
	@Interval int = 0
)
RETURNS TABLE 
AS
RETURN 
(
	  SELECT MAX(ApexSQL.FTruncateDate(MeasuredAt, [ApexSQL].[CalculateInterval](@StartDate, @EndDate, @Interval) ))  as X , AVG(Value) as Y
      FROM   [ApexSQL].[MonitorMeasuredValues]
      WHERE MeasuredAt >= @StartDate AND MeasuredAt <= @EndDate  AND  
			MeasurementId = @MeasurmentId AND    
			SourceId = @SourceId
      GROUP BY ApexSQL.FGetDateDiff(MeasuredAt , [ApexSQL].[CalculateInterval](@StartDate, @EndDate, @Interval) )
)
GO



--returns the X(Time),Y(Value),Serie(Name of metric), for creating the charts with more than one metric
CREATE FUNCTION [ApexSQL].[MeasuredValueMultiLineChart]
(
	@SourceId uniqueidentifier, 
	@MeasurmentId  uniqueidentifier, 
	@StartDate DateTimeOffset, 
	@EndDate DateTimeOffset,
	@Interval int = 0
)
RETURNS @result TABLE 
(
    X datetimeoffset NOT NULL,
    Y float NOT NULL,
	Serie NVARCHAR(256)
)
AS
BEGIN
	
	declare @serie NVARCHAR(256);
	SELECT @serie = [ApexSQL].[MetricIdToName](@MeasurmentId)
	insert into @result
	SELECT MAX(ApexSQL.FTruncateDate(MeasuredAt, [ApexSQL].[CalculateInterval](@StartDate, @EndDate, @Interval) ))  as X , AVG(Value) as Y, MAX(@serie) as Serie
    FROM   [ApexSQL].[MonitorMeasuredValues]
    WHERE MeasuredAt >= @StartDate AND MeasuredAt <= @EndDate  AND  
	      MeasurementId = @MeasurmentId AND    
		  SourceId = @SourceId
     GROUP BY ApexSQL.FGetDateDiff(MeasuredAt , [ApexSQL].[CalculateInterval](@StartDate, @EndDate, @Interval) )
     ORDER BY X
	 RETURN
END
GO



--Returns pie chart data X(Type),Y(%)
CREATE FUNCTION [ApexSQL].[MeasuredValuePieChart]
(
	@SourceId uniqueidentifier, 
	@MeasurmentId  uniqueidentifier, 
	@StartDate DateTimeOffset, 
	@EndDate DateTimeOffset
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT Value as X, count(*) * 100.0 / SUM(count(*)) over() as Y
	FROM   [ApexSQL].[MonitorMeasuredValues]
	 WHERE MeasuredAt >= @StartDate AND MeasuredAt <= @EndDate  AND  
			MeasurementId = @MeasurmentId AND    
			SourceId = @SourceId
	GROUP BY [Value]
)
GO




--This is specific function to be used wherever is required to provide the pie-chart for alerts data
CREATE FUNCTION [ApexSQL].[AlertSeverityPieChart]
(
	@StartDate DateTimeOffset, 
	@EndDate DateTimeOffset,
	@SourceId uniqueidentifier
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT Severity as X, count(*) * 100.0 / SUM(count(*)) over() as Y
	FROM   [ApexSQL].[MonitorAlerts]
	WHERE TimeRaised >= @StartDate AND TimeRaised <= @EndDate AND SourceId in (SELECT * from ApexSQL.GetAllSourcesForMachine (@SourceID))
	GROUP BY [Severity]
)
GO




