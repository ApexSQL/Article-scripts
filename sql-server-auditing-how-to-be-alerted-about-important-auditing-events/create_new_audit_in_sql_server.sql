USE [master]
GO

CREATE SERVER AUDIT [Audit Login Changes]
TO FILE 
(	FILEPATH = N'C:\SqlAudits\'
	,MAXSIZE = 1024 MB
	,MAX_FILES = 10
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = '<enter_appropriate_guid_here>'
)
ALTER SERVER AUDIT [Audit Login Changes] WITH (STATE = ON)
GO