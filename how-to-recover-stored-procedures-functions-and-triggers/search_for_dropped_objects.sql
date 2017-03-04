SELECT
       *
  FROM sys.fn_dblog(NULL, NULL)
WHERE [transaction name] IN ('DROPOBJ');