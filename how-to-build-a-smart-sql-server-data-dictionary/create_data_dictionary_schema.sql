-- Create database [DataDictionary]
IF (NOT EXISTS(SELECT * FROM sys.databases WHERE name='DataDictionary'))
BEGIN
	CREATE DATABASE [DataDictionary]
END
GO

USE [DataDictionary]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create table [dbo].[DataDictionary]
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID (N'[dbo].[DataDictionary]'))
BEGIN
	CREATE TABLE DataDictionary
	(
		ID int primary key identity(1,1),
		ChangeDate [datetime],
		[Server] [varchar](128),
		[Database] [varchar](128), 
		ObjectType [varchar](50) ,
		Name [varchar](128) ,
		Owner [varchar](128) ,
		ObjectID [int],
		DiffCode [bit] , 
		DiffType [char](2) ,
		DiffANSI [varchar](5) ,
		DiffAssembly [varchar](5) ,
		DiffAssemblyClass [varchar](5) ,
		DiffAssemblyMethod [varchar](5) ,
		DiffBaseType [varchar](5) ,
		DiffBody [varchar](5) ,
		DiffBoundDefault [varchar](5) ,
		DiffBoundDefaults [varchar](5) ,
		DiffBoundRule [varchar](5) ,
		DiffBoundRules [varchar](5) ,
		DiffChangeTracking [varchar](5) ,
		DiffCheckConstraints [varchar](5) ,
		DiffCLRName [varchar](5) ,
		DiffColumnOrder [varchar](5) ,
		DiffColumns [varchar](5) ,
		DiffDataspace [varchar](5) ,
		DiffDefaultConstraints [varchar](5) ,
		DiffDefaultSchema [varchar](5) ,
		DiffDurability [varchar](5) ,
		DiffExtendedProperties [varchar](5) ,
		DiffFiles [varchar](5) ,
		DiffForeignKeys [varchar](5) ,
		DiffFulltextIndex [varchar](5) ,
		DiffIdentities [varchar](5) ,
		DiffIndexes [varchar](5) ,
		DiffLockEscalation [varchar](5) ,
		DiffManifestFile [varchar](5) ,
		DiffMemoryOptimized [varchar](5) ,
		DiffNullable [varchar](5) ,
		DiffOwner [varchar](5) ,
		DiffParameters [varchar](5) ,
		DiffPermissions [varchar](5) ,
		DiffPermissionSet [varchar](5) ,
		DiffPrimaryKey [varchar](5) ,
		DiffReturnType [varchar](5) ,
		DiffScale [varchar](5) ,
		DiffSize [varchar](5) ,
		DiffStatistics [varchar](5) ,
		DiffUnique [varchar](5) ,
		DiffUserLogin [varchar](5) ,
		DiffXMLColumnSet [varchar](5) ,
		DiffXMLIndexes [varchar](5) ,
		DDL [nvarchar] (max)
	)
END
GO

-- Create stored procedure [dbo].[FillDataDictionary]
CREATE PROCEDURE [dbo].[FillDataDictionary]
@xmlLocation varchar(150)
AS
BEGIN
	DECLARE @COMMAND NVARCHAR(MAX)
	SET @COMMAND = N'SELECT CONVERT(XML, BulkColumn) AS XMLData
	INTO ##XMLwithOpenXML
	FROM OPENROWSET(BULK '''+ @xmlLocation +''', SINGLE_BLOB) AS x';
	
	EXEC sp_executesql @COMMAND

	DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)
		
	SELECT @XML = XMLData FROM ##XMLwithOpenXML
	EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML
	
	DROP TABLE ##XMLwithOpenXML

	INSERT INTO DataDictionary
	SELECT	GETDATE() AS ChangeDate,
			[Server],
			[Database], 
			[ObjectType], 
			[Name], 
			[Owner], 
			[ObjectID],
			[DiffCode], 
			[DiffType], 
			[DiffANSI], 
			[DiffAssembly], 
			[DiffAssemblyClass], 
			[DiffAssemblyMethod], 
			[DiffBaseType], 
			[DiffBody], 
			[DiffBoundDefault], 
			[DiffBoundDefaults], 
			[DiffBoundRule], 
			[DiffBoundRules], 
			[DiffChangeTracking], 
			[DiffCheckConstraints], 
			[DiffCLRName], 
			[DiffColumnOrder], 
			[DiffColumns], 
			[DiffDataspace], 
			[DiffDefaultConstraints], 
			[DiffDefaultSchema], 
			[DiffDurability], 
			[DiffExtendedProperties], 
			[DiffFiles], 
			[DiffForeignKeys], 
			[DiffFulltextIndex], 
			[DiffIdentities], 
			[DiffIndexes], 
			[DiffLockEscalation], 
			[DiffManifestFile], 
			[DiffMemoryOptimized], 
			[DiffNullable], 
			[DiffOwner], 
			[DiffParameters], 
			[DiffPermissions], 
			[DiffPermissionSet], 
			[DiffPrimaryKey], 
			[DiffReturnType], 
			[DiffScale], 
			[DiffSize], 
			[DiffStatistics], 
			[DiffUnique], 
			[DiffUserLogin], 
			[DiffXMLColumnSet], 
			[DiffXMLIndexes],
			[DDL]
	FROM OPENXML(@hDoc, 'root/*/*')
	WITH 
	(
		ObjectType [varchar](50) '@mp:localname',
		[Server] [varchar](50) '../../Server1',
		[Database] [varchar](50) '../../Database1', 
		Name [varchar](50) 'Name',
		Owner [varchar](50) 'Owner1',
		ObjectID [int] 'ObjectID1',
		DiffCode [bit] 'Diff_Code', 
		DiffType [char](2) 'DiffType',
		DiffANSI [varchar](5) 'DiffANSI',
		DiffAssembly [varchar](5) 'DiffAssembly',
		DiffAssemblyClass [varchar](5) 'DiffAssemblyclass',
		DiffAssemblyMethod [varchar](5) 'DiffAssemblymethod',
		DiffBaseType [varchar](5) 'DiffBasetype',
		DiffBody [varchar](5) 'DiffBody',
		DiffBoundDefault [varchar](5) 'DiffBounddefault',
		DiffBoundDefaults [varchar](5) 'DiffBounddefaults',
		DiffBoundRule [varchar](5) 'DiffBoundrule',
		DiffBoundRules [varchar](5) 'DiffBoundrules',
		DiffChangeTracking [varchar](5) 'DiffChangetracking',
		DiffCheckConstraints [varchar](5) 'DiffCheckconstraints',
		DiffCLRName [varchar](5) 'DiffCLRname',
		DiffColumnOrder [varchar](5) 'DiffColumnorder',
		DiffColumns [varchar](5) 'DiffColumns',
		DiffDataspace [varchar](5) 'DiffDataspace',
		DiffDefaultConstraints [varchar](5) 'DiffDefaultconstraints',
		DiffDefaultSchema [varchar](5) 'DiffDefaultschema',
		DiffDurability [varchar](5) 'DiffDurability',
		DiffExtendedProperties [varchar](5) 'DiffExtendedproperties',
		DiffFiles [varchar](5) 'DiffFiles',
		DiffForeignKeys [varchar](5) 'DiffForeignkeys',
		DiffFulltextIndex [varchar](5) 'DiffFulltextindex',
		DiffIdentities [varchar](5) 'DiffIdentities',
		DiffIndexes [varchar](5) 'DiffIndexes',
		DiffLockEscalation [varchar](5) 'DiffLockescalation',
		DiffManifestFile [varchar](5) 'DiffManifestfile',
		DiffMemoryOptimized [varchar](5) 'DiffMemoryoptimized',
		DiffNullable [varchar](5) 'DiffNullable',
		DiffOwner [varchar](5) 'DiffOwner',
		DiffParameters [varchar](5) 'DiffParameters',
		DiffPermissions [varchar](5) 'DiffPermissions',
		DiffPermissionSet [varchar](5) 'DiffPermissionset',
		DiffPrimaryKey [varchar](5) 'DiffPrimarykey',
		DiffReturnType [varchar](5) 'DiffReturntype',
		DiffScale [varchar](5) 'DiffScale',
		DiffSize [varchar](5) 'DiffSize',
		DiffStatistics [varchar](5) 'DiffStatistics',
		DiffUnique [varchar](5) 'DiffUnique',
		DiffUserLogin [varchar](5) 'DiffUserlogin',
		DiffXMLColumnSet [varchar](5) 'DiffXMLcolumnset',
		DiffXMLIndexes  [varchar](5) 'DiffXMLindexes',
		DDL [nvarchar](max) 'SourceDDL'
	)

EXEC sp_xml_removedocument @hDoc

END

