----------------------------------------------------------------------------------------------------
--This report will show longest running transactions with appropriate details (when has the transaction occurred, user that run it…)
--Report can be further configured by adding more table columns to the SELECT statement
----------------------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Top_10_longest_running_transactions]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT distinct TOP 10 TRANSACTION_ID, CAST(TRANSACTION_END - TRANSACTION_BEGIN as TIME) AS "Transatcion_duration", USER_NAME, TRANSACTION_BEGIN, TRANSACTION_DESCRIPTION FROM [dbo].[APEXSQL_LOG_OPERATION] ORDER BY CAST(TRANSACTION_END - TRANSACTION_BEGIN as TIME) DESC
END


GO


