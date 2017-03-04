-----------------------------------------------------------------------------------
--This report will report will show number of operations by operation type
-----------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Operation_count_by__operation_type]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT OPERATION_TYPE, COUNT(OPERATION_TYPE) as "Operation count" FROM [dbo].[APEXSQL_LOG_OPERATION] GROUP BY OPERATION_TYPE

END

GO


