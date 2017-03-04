
---------------------------------------------------------------------------
--This report will show number of specific operations separated per date
---------------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Operation_count_by_date_and_type]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT CONVERT(DATE, TRANSACTION_BEGIN) as "Date", OPERATION_TYPE, COUNT(OPERATION_TYPE) as "Operation count" FROM [dbo].[APEXSQL_LOG_OPERATION] GROUP BY OPERATION_TYPE, CONVERT(DATE, TRANSACTION_BEGIN)

END

GO


