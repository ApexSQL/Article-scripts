USE [ACMEDBNEW];
GO
CREATE DATABASE AUDIT SPECIFICATION [ObjectUseSpecification]
      FOR SERVER AUDIT [AuditObjectUsage]
      ADD (DELETE ON OBJECT::dbo.Customers BY [public]),
      ADD (INSERT ON OBJECT::dbo.Customers BY [public]),
      ADD (SELECT ON OBJECT::dbo.Customers BY [public]),
      ADD (UPDATE ON OBJECT::dbo.Customers BY [public]),
      ADD (EXECUTE ON OBJECT::dbo.Customers BY [db_owner]),
      ADD (EXECUTE ON OBJECT::dbo.Invoices BY [db_securityadmin])
      WITH (STATE = ON);
GO