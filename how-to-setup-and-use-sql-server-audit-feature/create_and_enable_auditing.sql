CREATE SERVER AUDIT [AdventureWorksAudit_DDL_Access] TO FILE 
(      FILEPATH = N'D:\TestAudits\'
      ,MAXSIZE = 10 MB
)
WITH 
(      QUEUE_DELAY = 1000
      ,ON_FAILURE = CONTINUE
)
ALTER SERVER AUDIT [AdventureWorksAudit_DDL_Access]WITH (STATE = ON)
GO