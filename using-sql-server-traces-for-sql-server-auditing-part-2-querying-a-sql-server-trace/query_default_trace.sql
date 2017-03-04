SELECT
       XE.name AS EventLabel ,
       x.subclass_name ,
       y.DatabaseName ,
       y.DatabaseID ,
       y.NTDomainName ,
       y.ApplicationName ,
       y.LoginName ,
       y.StartTime ,
       y.TargetUserName ,
       y.TargetLoginName ,
       y.SessionLoginName
  FROM
       sys.fn_trace_gettable((SELECT
	       REVERSE(SUBSTRING(REVERSE(path),
		CHARINDEX('\', REVERSE(path)), 256))
	       + 'log.trc'
       FROM sys.traces WHERE is_default = 1), DEFAULT)y
       
  JOIN sys.trace_events XE
       ON
       y.EventClass
       =
       XE.trace_event_id
       JOIN sys.trace_subclass_values x
       ON
       x.trace_event_id
       =
       XE.trace_event_id
   AND
       x.subclass_value
       =
       y.EventSubClass
WHERE
XE.name IN ( 'Audit Login Failed',
	      'Audit Addlogin Event',
	      'Audit Add DB User Event' )
AND
       x.StartTime
       >
       DATEADD(mi, -5, GETDATE());