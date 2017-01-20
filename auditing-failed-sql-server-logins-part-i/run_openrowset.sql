SELECT a.*
FROM OPENROWSET('MSDASQL', 'DRIVER={SQL Server};SERVER=Remote1;UID='
 manager ';PWD=' MyPass '', pubs.dbo.customers) AS a
ORDER BY a.fname