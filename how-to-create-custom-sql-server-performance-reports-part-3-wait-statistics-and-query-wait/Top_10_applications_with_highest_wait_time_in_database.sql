-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
DECLARE @SourceId uniqueidentifier	
DECLARE @DatabaseId uniqueidentifier
DECLARE @StartTime datetimeoffset(7)
DECLARE @EndTime datetimeoffset(7)	


SET @SourceId = [ApexSQL].[SQLServerNameToId] ('<SQL Server name>')  -- Enter SQL Server name
SET @DatabaseId = [ApexSQL].[SourceNameToId] ('ASW2014') -- Enter the database name here
SET @StartTime = '2017-2-1 06:00:00.0000000 +01:00'
SET @EndTime = '2017-2-28 06:00:00.0000000 +01:00'

-- Top 10 wait types with the highest wait time as percent of total wait time on specified SQL Server

SELECT Top 10 LI.Name as [Application], SUM (WaitTime)  as [Wait time] 
FROM [ApexSQLMonitor].[ApexSQL].[MonitorQueryWaits] QW LEFT JOIN 
[ApexSQLMonitor].[ApexSQL].[MonitorQueryLookupInfo] LI ON LI.Id = QW.ApplicationNameId
WHERE Li.Type = 3 AND QW.SourceId = @SourceId AND QW.DatabaseNameId = @DatabaseId
GROUP BY LI.Name 
ORDER by [Wait time] DESC
