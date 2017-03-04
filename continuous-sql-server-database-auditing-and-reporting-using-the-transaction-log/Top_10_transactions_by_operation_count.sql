-----------------------------------------------------------------------------------
--This report will show top 10 transactions that have included the most operations
-----------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Top_10_transactions_by_operation_count]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT TOP 10 TRANSACTION_ID, MAX(USER_NAME) AS "Username", MAX(TRANSACTION_BEGIN) as "Start time", COUNT(TRANSACTION_ID) AS "Operation count" FROM [dbo].[APEXSQL_LOG_OPERATION] GROUP BY TRANSACTION_ID ORDER BY COUNT(TRANSACTION_ID) DESC

END

GO


