USE AdventureWorks2012
GO
SET IDENTITY_INSERT Production.Illustration ON
INSERT INTO Production.Illustration 
(IllustrationID,Diagram,ModifiedDate)
SELECT * FROM AdventureWorks2012_Restored.Production.Illustration
SET IDENTITY_INSERT Production.Illustration OFF