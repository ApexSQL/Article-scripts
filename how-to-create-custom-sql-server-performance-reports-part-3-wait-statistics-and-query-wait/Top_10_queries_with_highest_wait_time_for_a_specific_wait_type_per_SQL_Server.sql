-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
DECLARE @SourceId uniqueidentifier	
DECLARE @StartTime datetimeoffset(7)
DECLARE @EndTime datetimeoffset(7)
DECLARE @WaitType NVARCHAR(100)	

SET @SourceId = [ApexSQL].[SQLServerNameToId] ('WIN-ECJIMF4DK6U')  -- Enter SQL Server name
SET @StartTime = '2017-2-1 06:00:00.0000000 +01:00'
SET @EndTime = '2017-2-28 06:00:00.0000000 +01:00'
SET @WaitType = 'CXPACKET' -- Enter the Wait type name here

SELECT TOP 10 
	 QW.[SqlHandle]
	,MAX(QT.SqlText) as [T-SQL]
	,QW.[Plan handle]
	,MAX(MD.DatabaseName) as [Database]
	,SUM(QW.[WaitTime]) as [Total wait]
  FROM [ApexSQLMonitor].[ApexSQL].[MonitorQuerySingleWaitsView] QW 
  LEFT JOIN ApexSQL.[MonitorQueryTexts]  QT ON QW.QueryTextId = QT.Id
  LEFT JOIN ApexSQL.[MonitorDatabases] MD ON QW.DatabaseNameId = MD.Id
WHERE WHERE WaitTypeName = @WaitType AND QT.SqlText IS NOT NULL AND [MeasuredAt] >= @StartTime AND [MeasuredAt]<= @EndTime
  GROUP BY 
    QW.[QueryTextId] 
      ,QW.[SqlHandle]
      ,QW.[Plan handle]
      ,QW.[StmOffsetStart]
      ,QW.[StmOffsetEnd]
   ,QW.[SourceId]
   ,QW.DatabaseNameId
   ,QW.[WaitTypeName]
   ORDER By [Total wait] DESC
