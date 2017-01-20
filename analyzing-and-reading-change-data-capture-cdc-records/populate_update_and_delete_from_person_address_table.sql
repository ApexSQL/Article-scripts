INSERT INTO [Person].[Address] ([AddressID], [AddressLine1], [AddressLine2], 
[City],
[StateProvinceID]) VALUES (32522, N'1234 Rodeo Drive', NULL, N'New York', 79)

INSERT INTO [Person].[Address] ([AddressID], [AddressLine1], [AddressLine2], 
[City],
[StateProvinceID]) VALUES (32523, N'2345 Red Hills Way', NULL, N'Bellevue', 79)

INSERT INTO [Person].[Address] ([AddressID], [AddressLine1], [AddressLine2], 
[City],
[StateProvinceID]) VALUES (32524, N'3456 Big City Street', NULL, N'Edmonds', 79)

UPDATE [Person].[Address] SET [AddressLine1] = N'5415 La Valetta Blv.'	,
[City] = 
N'Seattle' WHERE [AddressID] = 16

DELETE FROM [Person].[Address] WHERE [AddressID] = 32524