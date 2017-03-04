SELECT
       CONVERT(varchar(max),
			SUBSTRING([RowLog Contents 0],
			33,
			LEN([RowLog Contents 0]))) AS Script
  FROM fn_dblog(NULL, NULL)
WHERE
       Operation
       =
       'LOP_DELETE_ROWS'
   AND
       Context
       =
       'LCX_MARK_AS_GHOST'
   AND
       AllocUnitName
       =
       'sys.sysobjvalues.clst'
   AND [TRANSACTION ID] IN (SELECT DISTINCT
                                   [TRANSACTION ID]
                              FROM sys.fn_dblog(NULL, NULL)
                            WHERE
                                  Context IN ('LCX_NULL')
                              AND Operation IN ('LOP_BEGIN_XACT')
                              AND
                                   [Transaction Name]
                                   =
                                   'DROPOBJ'
                              AND CONVERT(nvarchar(11), [Begin Time])
					BETWEEN
						'2013/07/31'
					AND
						'2013/08/1')
   AND
       SUBSTRING([RowLog Contents 0], 33, LEN([RowLog Contents 0])) <> 0;
GO