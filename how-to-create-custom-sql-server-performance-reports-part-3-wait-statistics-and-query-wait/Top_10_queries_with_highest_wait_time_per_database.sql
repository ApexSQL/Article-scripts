-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
DECLARE @DatabaseId uniqueidentifier
DECLARE @SourceId uniqueidentifier	
DECLARE @StartTime datetimeoffset(7)
DECLARE @EndTime datetimeoffset(7)

set @StartDate  = '2017-1-1 06:00:00.0000000 +01:00'
set @EndDate = '2017-1-21 06:00:00.0000000 +01:00'


SET @SourceId = [ApexSQL].[SourceNameToId] ('WIN-ECJIMF4DK6U')  -- Enter SQL Server name
SET @DatabaseId = [ApexSQL].[SourceNameToId] ('ASW2014') -- Enter the database name here
 
 -- Return Top 10 queries with highest wait time over the specified time period for the selected database
---------------------------------------------------------------------
SELECT TOP 10
       QW.[SqlHandle] as [Query handle]
	  ,MAX(QT.[SqlText]) as [T-SQL]  
      ,SUM([WaitTime]) as [Total wait]
	  ,MAX(MD.[DatabaseName]) as [Database]
      ,QW.[PlanHandle] as [Plan handle]
      
  FROM [ApexSQLMonitor].[ApexSQL].[MonitorQueryWaits] QW 
  LEFT JOIN ApexSQL.[MonitorQueryTexts]  QT ON QW.QueryTextId = QT.Id
  LEFT JOIN ApexSQL.[MonitorDatabases] MD ON QW.DatabaseNameId = MD.Id
  WHERE QW.DatabaseNameId = @DatabaseId
 AND [MeasuredAt] >= @StartTime
 AND [MeasuredAt]<= @EndTime
  GROUP BY  
       QW.[QueryTextId] 
      ,QW.[SqlHandle]
      ,QW.[PlanHandle]
      ,QW.[StmOffsetStart]
      ,QW.[StmOffsetEnd]
   ,QW.[SourceId]
   ,QW.DatabaseNameId
ORDER BY [Total wait] DESC

