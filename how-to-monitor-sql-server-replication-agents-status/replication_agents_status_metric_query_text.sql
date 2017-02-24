--For all publications:
USE distribution
SELECT status FROM dbo.MSReplication_monitordata
WHERE publication = 'ALL'
--For particular publication:
USE distribution
SELECT status FROM dbo.MSReplication_monitordata
WHERE publication = '<publication_name>'

