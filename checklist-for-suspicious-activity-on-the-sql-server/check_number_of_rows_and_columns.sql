SELECT DB_NAME() DatabaseName
	,s.NAME + '.' + o.NAME TableName
	,SUM(p.rows) RecordCount
	,COUNT(c.column_id) ColumnCount
FROM sys.indexes i
INNER JOIN sys.partitions p ON i.object_id = p.object_id
	AND i.index_id = p.index_id
INNER JOIN sys.objects o ON o.object_id = i.object_id
INNER JOIN sys.columns c ON o.object_id = c.object_id
INNER JOIN sys.schemas s ON o.object_id = s.schema_id
WHERE i.index_id < 2
	AND o.type = 'U'
GROUP BY s.NAME
	,o.NAME
ORDER BY s.NAME
	,o.NAME;