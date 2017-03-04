-----------------------------------------------------------------------------------------------
--This report will show top 10 transactions count for database tables.
--To configure time-frame, set @start_date and @end_date variables to specific from/to dates
--e.g. SET @start_date = '2016-06-01', SET @end_date = '2016-12-01’
-----------------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Top_10_transactions_count_by_table]
@start_date as varchar(50),
@end_date as varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT TOP 10 OBJECT_NAME, count(distinct TRANSACTION_ID) as "Transaction Count" FROM [dbo].[APEXSQL_LOG_OPERATION] WHERE TRANSACTION_BEGIN > @start_date AND TRANSACTION_END < @end_date group by OBJECT_NAME ORDER BY "Transaction Count" DESC

END

GO


