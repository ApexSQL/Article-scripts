---------------------------------------------------------------------------------------
--This report will show  number of operations per date for specific operation type.
--To configure the report for specific operation typesimply set the @operation_type variable to a specific operation (INSERT, DELETE, UPDATE...)
--(e.g. @operation_type = 'DELETE' to get the results for delete operations)
---------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Operations_count_by _type_and_date_per_operation]
@operation_type as varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT CONVERT(DATE, TRANSACTION_BEGIN) as "Date", OPERATION_TYPE, COUNT(OPERATION_TYPE) as "Operation count" FROM [dbo].[APEXSQL_LOG_OPERATION] WHERE OPERATION_TYPE = @operation_type GROUP BY OPERATION_TYPE, CONVERT(DATE, TRANSACTION_BEGIN)

END

GO


