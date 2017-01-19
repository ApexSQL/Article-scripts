CREATE TABLE dbo.Visits 

/* ID = 754101727 */

(VisitID int NOT NULL, 
 PatientID int NULL, 
 Visitdate date NULL, 
 VisitTime time(7)NULL, 
 Diagnosis nvarchar(200)COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
 treatment nvarchar(500)COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
 Comments nvarchar(500)COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
 VisitStatus bit NULL, 
 Recommendation nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS NULL
);
--	RECOVERED ROWS FROM [dbo].[Visits], ID = 754101727
INSERT INTO dbo.Visits(VisitID, 
                       PatientID, 
                       Visitdate, 
                       VisitTime, 
                       Diagnosis, 
                       treatment, 
                       Comments, 
                       VisitStatus, 
                       Recommendation
                      )
VALUES(1, 
       1, 
       '20130105', 
       '19:00:00', 
       N'Diabetes acc' COLLATE SQL_Latin1_General_CP1_CI_AS, 
       N'insuline' COLLATE SQL_Latin1_General_CP1_CI_AS, 
       N'general state well' COLLATE SQL_Latin1_General_CP1_CI_AS, 
       0, 
       N'A healthy diet and lifestyle'
      );