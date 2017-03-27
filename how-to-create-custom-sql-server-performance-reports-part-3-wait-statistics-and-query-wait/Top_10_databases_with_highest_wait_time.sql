-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
DECLARE @SourceId uniqueidentifier	
DECLARE @StartTime datetimeoffset(7)
DECLARE @EndTime datetimeoffset(7)	


SET @SourceId = [ApexSQL].[SQLServerNameToId] ('WIN-ECJIMF4DK6U')  -- Enter SQL Server name
SET @StartTime = '2017-2-1 06:00:00.0000000 +01:00'
SET @EndTime = '2017-2-28 06:00:00.0000000 +01:00'

-- Top 10 databases with highest wait time 

SELECT TOP 10 MAX(MD.[DatabaseName]) as [Database]
      ,SUM([WaitTime]) as [TotalWait]
  FROM [ApexSQL].[MonitorQueryWaits] QW 
  LEFT JOIN   ApexSQL.[MonitorDatabases] MD ON QW.DatabaseNameId = MD.Id
  WHERE QW.SourceId = @SourceId AND QW.MeasuredAt > @StartTime AND QW.MeasuredAt < @EndTime
  GROUP BY [DatabaseNameId]
  ORDER BY [TotalWait] DESC
GO
