SELECT LN.LoginName, count (E.Id)
 AS EventCount 
FROM ApexSQL.Event E
LEFT JOIN ApexSQL.ServerName SN ON  E.ServerNameId = SN.Id
LEFT JOIN ApexSQL.ApplicationName AN ON E.ApplicationNameId = AN.Id
LEFT JOIN ApexSQL.ClientHostName CHN ON E.ClientHostNameId = CHN.Id
LEFT JOIN ApexSQL.LoginName LN ON E.LoginNameId = LN.Id
LEFT JOIN ApexSQL.LoginSid LS ON E.LoginSidId = LS.Id
LEFT JOIN ApexSQL.DatabaseName DN ON E.DatabaseNameId = DN.Id
LEFT JOIN ApexSQL.SchemaName SCN ON E.SchemaNameId = SCN.Id 
LEFT JOIN ApexSQL.ObjectName OBN ON E.ObjectNameId = OBN.Id
LEFT JOIN ApexSQL.TextData TD ON E.TextDataId = TD.Id
LEFT JOIN ApexSQL.LoginName SLN ON E.SessionLoginNameId = SLN.Id
LEFT JOIN ApexSQL.ServerName LSN ON E.LinkedServerNameId = LSN.Id
LEFT JOIN ApexSQL.LoginName TLN ON E.TargetLoginNameId = TLN.Id
LEFT JOIN ApexSQL.LoginSid TLS ON E.TargetLoginSidId = TLS.Id
LEFT JOIN ApexSQL.UserName TUN ON E.TargetUserNameId = SN.Id
WHERE CreateTime
      > 
      ‘2013-07-03’ AND LN.LoginName is not null
GROUP BY LN.LoginName