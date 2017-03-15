-- Set the time range (this is just an example, and this part of query will be replaced when using in reporting application or SSRS with the parameters that will be feed directly from the application/SSRS)
---------------------------------------------------------------------
declare @StartDate datetimeoffset(7);
declare @EndDate  datetimeoffset(7);

declare @MachineName  nvarchar(256);

set @StartDate  = '2016-12-05 00:00:00.0000000 +01:00'
set @EndDate = '2017-1-15 00:00:00.0000000 +01:00'

set  @MachineName  = ApexSQL.SourceNameToId ('SERVER2012R2-L1') -- Enter machine/computer name

-- This is the main part of the script that returns the X(Type),Y(Value) table.
-- It is useful for status metrics with two states e.g system aviability 
---------------------------------------------------------------------
SELECT ApexSQL.AlertSeverityToStringConverter (X) as Severity, Y 
FROM [ApexSQL].[AlertSeverityPieChart] (
   @StartDate,
   @EndDate,
   @MachineName )