-----------------------------------------------------------
--This report will show all transactions per day
-----------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Transactions_per_Day]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT CONVERT(DATE, TRANSACTION_BEGIN) AS "Date", count(distinct TRANSACTION_ID) as "Transaction Count" FROM [dbo].[APEXSQL_LOG_OPERATION] group by CONVERT(DATE, TRANSACTION_BEGIN)

END

GO


