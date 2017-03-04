-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------

declare @MeasurementId uniqueidentifier; 
declare @ServerId uniqueidentifier; 
declare @DatabaseId uniqueidentifier; 

set @MeasurementId = ApexSQL.MetricNameToId('AvgFragmentationInPercent') --This is where the Average index fragmentation % metric is set (Do not change)

set @ServerId = ApexSQL.SourceNameToId ('.') --Enter the SQL Server name here

set @DatabaseId = ApexSQL.SourceNameToId ('ADW2014') --Enter the database name here for which report should be created

set @Fragmentation = 80 --Minimal fragmentation percent of index to be displayed in report. Set the value between 0 and 100 (usual value is 70 - 80)


--Report on indexes with Fragmentation % higher than selected for the specified database that is hosted in the specified SQL Server
 
select ApexSQL.[SourceIdToName](
	R.[SourceId]) as [Index Name],
    R.[Value] as [Fragmentation],
   	MI.[TableName],
	R.[MeasuredAt]
	
from (
     select M.[SourceId],
            M.[MeasurementId],
            M.[Value],
   M.[MeasuredAt],
            row_number() over(partition by M.SourceId,M.MeasurementId order by M.MeasuredAt desc) as rn
     from [ApexSQL].[MonitorMeasuredValues] as M 
  WHERE M.MeasurementId = @MeasurementId AND 
  M.SourceId in 
  (SELECT * FROM ApexSQL.GetAllIndexesForDatabase (@DatabaseId)
   )) as R 
   LEFT JOIN [ApexSQL].[MonitorIndexes] MI on MI.Id=R.SourceId
where R.rn <= 1 and R.Value > 10
ORDER BY R.[Value] DESC