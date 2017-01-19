CREATE PROCEDURE [dbo].[usp_DeleteOldBackupFiles] @path NVARCHAR(256),
	@extension NVARCHAR(10),
	@age_hrs INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DeleteDate NVARCHAR(50)
	DECLARE @DeleteDateTime DATETIME

	SET @DeleteDateTime = DateAdd(hh, - @age_hrs, GetDate())

        SET @DeleteDate = (Select Replace(Convert(nvarchar, @DeleteDateTime, 111), '/', '-') + 'T' + Convert(nvarchar, @DeleteDateTime, 108))

	EXECUTE master.dbo.xp_delete_file 0,
		@path,
		@extension,
		@DeleteDate,
		1
END