SELECT
       REVERSE(SUBSTRING(REVERSE(path), CHARINDEX('\', REVERSE(path)), 256))
  FROM sys.traces WHERE is_default = 1;