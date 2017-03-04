USE ApexSQLMonitor
GO

--The purpose of the function is to return the time interval that will be used for interpolation of the metric values
CREATE FUNCTION [ApexSQL].[CalculateInterval]
(
	@From     datetimeoffset,
	@To       datetimeoffset,
	@Interval int
)
RETURNS int
AS
BEGIN
	DECLARE @period int;

	SET @period = DATEDIFF(Minute ,  @From, @To)

	IF @Interval <> 0 RETURN @Interval

	-- Period less than hour interval is one minute
	IF @period < 1 * 60 RETURN 1;

	-- Period less than 24-hour interval is five minute
	IF @period < 24 * 60 RETURN 5;
	
	-- Period less than 7-day interval is one hour
	IF @period < 7 * 24 * 60 RETURN 60;

	-- Period bigger than 7-day interval is four hour
	RETURN 240;
END
GO


--Converts SQL Server agent status type to string (Stopped, Start pending, Stop pending, Running, Continue pending, Pause pending and Paused) 
CREATE FUNCTION [ApexSQL].[AgentStateTypeConverter]
(
	@value     int
)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @value = 1 RETURN ' Stopped'

	IF @value = 2 RETURN 'Start pending'

	IF @value = 3 RETURN 'Stop pending'

	IF @value = 4 RETURN 'Running'
	
	IF @value = 5 RETURN 'Continue pending'
	
	IF @value = 6 RETURN 'Pause pending'

	IF @value = 7 RETURN 'Paused'

RETURN 'Unknown';
END
GO


--Converts source type to string (Machine, SQL Server, Database, Device, Index, Replica, AG Database)
CREATE FUNCTION [ApexSQL].[SourceTypeConverter] (@object INT)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @object = 1
		RETURN 'Machine'

	IF @object = 2
		RETURN 'SQL Server'

	IF @object = 3
		RETURN 'Database'

	IF @object = 4
		RETURN 'Device'

	IF @object = 5
		RETURN 'Index'

	IF @object = 6
		RETURN 'AlwaysOn Replica'

	IF @object = 7
		RETURN 'AlwaysOn Database'

	RETURN 'Unknown';
END
GO

--Converts system availability to string (Offline, Online)
CREATE FUNCTION [ApexSQL].[StatusConverter]
(
	@value     float
)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @value = 0 RETURN 'Offline'

	RETURN 'Online';
END
GO


--Converts the metric name to Id
CREATE FUNCTION [ApexSQL].[MetricNameToId]
(
	@MetricName  NVARCHAR(500)
)
RETURNS uniqueidentifier
AS
BEGIN
	
	DECLARE @Id uniqueidentifier;

	SELECT TOP 1 @Id = Id
		FROM ApexSQL.MonitorMeasurements 
		WHERE Name = @MetricName

	RETURN @Id
END
GO


--Converts the metric source name to Id
CREATE FUNCTION [ApexSQL].[SourceNameToId]
(
	@SourceName  NVARCHAR(500)
)
RETURNS uniqueidentifier
AS
BEGIN
	
	DECLARE @Id uniqueidentifier;

	SELECT TOP 1 @Id = Id
		FROM ApexSQL.MonitoredSourcesView 
		WHERE Name = @SourceName

	RETURN @Id
END
GO


--Converts the metric Id to name
CREATE FUNCTION [ApexSQL].[MetricIdToName]
(
	@MeasurmentId  uniqueidentifier
)
RETURNS NVARCHAR(500)
AS
BEGIN
	
	DECLARE @MeasurmentName NVARCHAR(500);

	SELECT TOP 1 @MeasurmentName = Name
		FROM ApexSQL.MonitorMeasurements 
		WHERE Id = @MeasurmentId

	RETURN @MeasurmentName
END
GO


--Converts the metric source id to name
CREATE FUNCTION [ApexSQL].[SourceIdToName]
(
	@SourceId  uniqueidentifier
)
RETURNS NVARCHAR(500)
AS
BEGIN
	
	DECLARE @SourceName NVARCHAR(500);

	SELECT TOP 1 @SourceName = Name
		FROM ApexSQL.MonitoredSourcesView 
		WHERE Id = @SourceId

	RETURN @SourceName
END
GO


--Converts SQL Server database status type to string (Restoring, Recovering, Recovery pending, Suspect, Emergency, Offline and Copying)
CREATE FUNCTION [ApexSQL].[DatabaseStateTypeConverter]
(
	@value     int
)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @value = 1 RETURN ' Restoring'

	IF @value = 2 RETURN 'Recovering'

	IF @value = 3 RETURN 'Recovery pending'

	IF @value = 4 RETURN 'Suspect'
	
	IF @value = 5 RETURN 'Emergency'
	
	IF @value = 6 RETURN 'Offline'

	IF @value = 7 RETURN 'Copying'

RETURN 'Unknown';
END
GO


--This function will return the alert severity as a string
CREATE FUNCTION [ApexSQL].[SeverityToStringConverter]
(
	@value     int
)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @value = 1 RETURN 'Low'
	IF @value = 2 RETURN 'Medium'
	IF @value = 3 RETURN 'High'

	RETURN 'Unknown';
END
GO


--Convert alert state to string (Not resolved, Ignored, Fixed, Known issue)
CREATE FUNCTION [ApexSQL].[AlertStateToStringConverter]
(
	@value     int
)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @value = 1 RETURN 'Ignored'
	IF @value = 2 RETURN 'Fixed'
	IF @value = 3 RETURN 'Known issue'

	RETURN 'Not resolved';
END
GO




CREATE FUNCTION [ApexSQL].[AlertSeverityToStringConverter]
(
	@Severity     int
)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @Severity = 1 RETURN 'Low'
	IF @Severity = 2 RETURN 'Medium'
	IF @Severity = 3 RETURN 'High'

	RETURN 'Unknown';
END
GO



--Converts alert review state to string (Yes, No)
CREATE FUNCTION [ApexSQL].[AlertCheckToStringConverter]
(
	@review int
)
RETURNS NVARCHAR(50)
AS
BEGIN
	IF @review = 0 RETURN 'No'

	RETURN 'Yes';
END
GO

--Convert alert severity string (Low, Medium, High) to Id (1, 2, 3) 
CREATE FUNCTION [ApexSQL].[AlertSeverityToNumberConverter]
(
	@severity     NVARCHAR(50)
)
RETURNS int
AS
BEGIN
	IF @severity = 'Low' RETURN 1
	IF @severity = 'Medium' RETURN 2
	IF @severity = 'High' RETURN 3
	IF @severity = 'All' RETURN 4

	RETURN -1;
END
GO



--Convert alert state string (Not resolved, Ignored, Fixed, Known issue) to Id (0, 1, 2, 3, 4)
CREATE FUNCTION [ApexSQL].[AlertStateToNumberConverter]
(
	@state     NVARCHAR(50)
)
RETURNS int
AS
BEGIN
	IF @state = 'Not fixed' RETURN 0
	IF @state = 'Ignored' RETURN 1
	IF @state = 'Fixed' RETURN 2
	IF @state = 'Known issue' RETURN 3
	IF @state = 'All' RETURN 4

	RETURN -1;
END
GO



--Returns all existing indexes in the specified database
CREATE FUNCTION [ApexSQL].[GetAllIndexesForDatabase]
(
	@DatabaseId uniqueidentifier
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT [Id]
  FROM [ApexSQLMonitor].[ApexSQL].[MonitoredObjectsView] 
  WHERE Type = 5 AND DatabaseId = @DatabaseId
)
GO


--Return all available indexes for SQL Server (for all databases)
CREATE FUNCTION [ApexSQL].[GetAllIndexesForServer] (@ServerId uniqueidentifier)
RETURNS TABLE 
AS
RETURN 
(
	SELECT [Id]
  FROM [ApexSQLMonitor].[ApexSQL].[MonitoredObjectsView] 
  WHERE Type = 5 AND ServerId = @ServerId
)
GO



--Returns all available sources for all performance metric (i.e indexes, Table name, database name etc.)
CREATE FUNCTION [ApexSQL].[GetAllSourcesForMachine] (@MachineId uniqueidentifier)
RETURNS TABLE 
AS
RETURN 
(
	SELECT [Id]
  FROM [ApexSQLMonitor].[ApexSQL].[MonitoredObjectsView] 
  WHERE Type > 0 AND MachineId = @MachineId
)
GO



--Return all sources Ids for specified SQL Server only
CREATE FUNCTION [ApexSQL].[GetAllSourcesSQLServer] (@ServerId uniqueidentifier)
RETURNS TABLE 
AS
RETURN 
(
	SELECT [Id]
  FROM [ApexSQLMonitor].[ApexSQL].[MonitoredObjectsView] 
  WHERE Type > 0 AND ServerId = @ServerId
)
GO
