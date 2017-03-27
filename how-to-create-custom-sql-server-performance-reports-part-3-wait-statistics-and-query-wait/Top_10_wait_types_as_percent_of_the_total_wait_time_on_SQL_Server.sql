-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
DECLARE @SourceId uniqueidentifier	
DECLARE @StartTime datetimeoffset(7)
DECLARE @EndTime datetimeoffset(7)	


SET @SourceId = [ApexSQL].[ServerNameToId] ('WIN-ECJIMF4DK6U')  -- Enter SQL Server name
SET @StartTime = '2017-01-20 15:53:14.2662215 +01:00';
SET @EndTime = '2017-02-28 15:53:14.2662215 +01:00';

-- Top 10 wait types with the highest wait time as percent of total wait time on specified SQL Server

WITH cte 
     AS (SELECT WaitTypeId, 
                ( [Value] * 100 ) / SUM([Value]) OVER (PARTITION BY 1) 
                AS   PercentOfTotalWait 
         FROM   [ApexSQL].[FGetWaitstatsCumulative] (
   @SourceId, 
  @StartTime, 
  @EndTime, 
  60*24*365)) 
SELECT TOP 10 WT.WaitTypeName,  [PercentOfTotalWait]
FROM   cte LEFT JOIN [ApexSQL].[MonitorWaitTypes] WT on WT.Id = WaitTypeId
ORDER BY [PercentOfTotalWait] desc
