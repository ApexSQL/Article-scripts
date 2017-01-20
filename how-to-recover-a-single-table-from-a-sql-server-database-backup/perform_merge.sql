USE AdventureWorks2012
GO
SET IDENTITY_INSERT Production.Illustration ON
MERGE Production.Illustration dest
USING (SELECT * FROM AdventureWorks2012_Restored.Production.Illustration src) AS src
              ON dest.IllustrationID = src.IllustrationID
WHEN MATCHED THEN UPDATE 
SET dest.Diagram = src.Diagram, dest.ModifiedDate = src.ModifiedDate
WHEN NOT MATCHED THEN INSERT
(IllustrationID,Diagram,ModifiedDate) VALUES 
(src.IllustrationID,src.Diagram,src.ModifiedDate);
SET IDENTITY_INSERT Production.Illustration OFF