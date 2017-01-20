SELECT [begin time], 
       [rowlog contents 1], 
       [Transaction Name], 
       Operation
  FROM sys.fn_dblog
   (NULL, NULL)
  WHERE operation IN
   ('LOP_DELETE_ROWS');