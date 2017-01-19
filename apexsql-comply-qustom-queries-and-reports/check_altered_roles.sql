SELECT LoginName, CreateTime, TextData 
AS     EventCount 
FROM   ApexSQLCrd.ApexSql.EventView
WHERE  TextData
LIKE  'ALTER SERVER ROLE%'
AND    ServerName = 'FUJITSUSQL2012'