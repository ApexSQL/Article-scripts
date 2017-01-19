INSERT INTO dbo.Appointments(AppID, 
                             PatientID, 
                             AppDate, 
                             AppTime, 
                             Diagnosis, 
                             Treatment, 
                             Comments, 
                             AppStatus
                            )
VALUES(1, 
       1, 
       '20110101', 
       '12:12:00', 
       N'2' COLLATE SQL_Latin1_General_CP1_CI_AS, 
       N'2' COLLATE SQL_Latin1_General_CP1_CI_AS, 
       N'2' COLLATE SQL_Latin1_General_CP1_CI_AS, 
       NULL
      );