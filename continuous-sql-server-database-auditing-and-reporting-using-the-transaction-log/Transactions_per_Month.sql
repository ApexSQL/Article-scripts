----------------------------------------------------------------------------------------------------------------------
--This report will show all transactions by the time frame specified in the @time_frame variable
--The @time_frame variable can be changed to adjust the precision per date/time.
--e.g. ‘YYYY-MM-DD-hh will show all transactions all the way to the per-hour level
----------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Transactions_per_Month]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @time_frame as varchar(50)
SET @time_frame = 'yyyy-MM'
SELECT FORMAT(TRANSACTION_BEGIN, @time_frame) AS "Date/Time", count(distinct TRANSACTION_ID) as "Transaction Count" FROM [dbo].[APEXSQL_LOG_OPERATION] group by FORMAT(TRANSACTION_BEGIN, @time_frame)

END

GO


