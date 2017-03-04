SELECT
       XE.name AS EventName , X.DatabaseName , X.ApplicationName , X.LoginName , 
COUNT(*) AS TotalCount
  FROM
       dbo.fn_trace_gettable
('C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\LOG\log.trc',
 DEFAULT)X
       JOIN sys.trace_events XE
       ON
       X.EventClass
       =
       XE.trace_event_id
GROUP BY
         XE.name , X.DatabaseName , X.ApplicationName, X.LoginName;