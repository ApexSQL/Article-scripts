USE [master];
GO
CREATE SERVER AUDIT [AuditObjectUsage] TO FILE (
              FILEPATH = N'C:\AUDITs\'
            , MAXSIZE = 15 MB
            , MAX_FILES = 10
            , RESERVE_DISK_SPACE = OFF
            )
      WITH (
            QUEUE_DELAY = 1000
            , ON_FAILURE = CONTINUE
            );
      ALTER SERVER AUDIT [AuditObjectUsage]
      WITH (STATE = ON);
GO