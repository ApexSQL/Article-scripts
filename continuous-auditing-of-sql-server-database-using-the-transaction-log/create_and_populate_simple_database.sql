CREATE TABLE [dbo].[Table001] (
	[id] VARCHAR(11) CONSTRAINT [Pid] PRIMARY KEY
	,[Name] VARCHAR(40) NOT NULL
	,
	)
GO

INSERT INTO [dbo].[Table001] (
	[id]
	,[Name]
	)
VALUES (
	'100'
	,'George'
	)

INSERT INTO [dbo].[Table001] (
	[id]
	,[Name]
	)
VALUES (
	'101'
	,'Nesha'
	)

INSERT INTO [dbo].[Table001] (
	[id]
	,[Name]
	)
VALUES (
	'102'
	,'Mark'
	)

INSERT INTO [dbo].[Table001] (
	[id]
	,[Name]
	)
VALUES (
	'103'
	,'Jack'
	)

INSERT INTO [dbo].[Table001] (
	[id]
	,[Name]
	)
VALUES (
	'104'
	,'Bear'
	)
GO