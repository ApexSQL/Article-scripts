INSERT
INTO AdventureWorks2012.dbo.AUDIT_LOG_TRANSACTIONS
(
     TABLE_NAME,
     TABLE_SCHEMA,
     AUDIT_ACTION_ID,
     HOST_NAME,
     APP_NAME,
     MODIFIED_BY,
     MODIFIED_DATE,
     [DATABASE]
)
VALUES(
'Currency',
'Sales',
2, --	ACTION ID For INSERT
CASE
WHEN
       LEN(HOST_NAME())
       <
       1 THEN ' '
    ELSE HOST_NAME()
END,
CASE
WHEN
       LEN(APP_NAME())
       <
       1 THEN ' '
    ELSE APP_NAME()
END,
SUSER_SNAME(),
GETDATE(),
'AdventureWorks2012'
);