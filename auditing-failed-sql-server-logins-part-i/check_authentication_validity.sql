SELECT FROM tblUser WHERE userid = ‘” + Request.QueryString[“UID”] + “’ AND password = ‘” + Request.QueryString[“PSW”] +
-- whatever ‘ OR 1 = 1 ––

--The resulting dynamic SQL will be:

SELECT FROM tblUser WHERE userid = ‘ whatever ‘ OR 1 = 1 ––’ AND password =

--The dynamic SQL will be executed, as the WHERE condition is always true (1 = 1):
SELECT
FROM tblUser
WHERE userid = ' whatever '
	OR 1 = 1

--A real SQL injection attack can be more complex and cause more damage than the previous example. The following will not just pass the validation, but will also insert an additional DROP TABLE command:

‘ whatever ‘ OR 1 = 1; DROP TABLE tblUSER –

