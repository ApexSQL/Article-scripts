SELECT LoginName, count (ID) 
AS EventCount 
FROM ApexSQLCrd.ApexSql.EventView 
WHERE CreateTime
      > 
      '2013-07-03' AND LoginName is not null
GROUP BY LoginName