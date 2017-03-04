CREATE TABLE Audit_Info
(
       EventTime            DATETIME,
       LoginName            VARCHAR(255),
       UserName             VARCHAR(255),
       HostName             VARCHAR(255),
       ApplicationName      VARCHAR(255),
       DatabaseName         VARCHAR(255),
       SchemaName           VARCHAR(255),
       ObjectName           VARCHAR(255),
       ObjectType           VARCHAR(255),      
       DDLCommand           VARCHAR(MAX)
)