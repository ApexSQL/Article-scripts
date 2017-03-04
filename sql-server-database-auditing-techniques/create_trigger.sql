CREATE TRIGGER PersonPerson_I
ON Person.Person
AFTER INSERT 
AS
   INSERT INTO dbo.repository (
TABLE_NAME,
		TABLE_SCHEMA,
		AUDIT_ACTION_ID,
		MODIFIED_BY,
		MODIFIED_DATE,
		[DATABASE]
	)
	values(
		'Person',
		'Person',
		'Insert',			
		SUSER_SNAME(),
		GETDATE(),
		'AdventureWorks2012'
	) GO