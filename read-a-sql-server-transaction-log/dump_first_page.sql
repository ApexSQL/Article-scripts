SELECT FILE_ID ('AdventureWorks2012_Log') AS 'File ID' 
-- to determine Log file ID = 2
DBCC PAGE (AdventureWorks2012, 2, 0, 2)