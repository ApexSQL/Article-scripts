EXEC sp_configure 'show advanced options', 1;
CREATE TABLE #Options (
             name varchar(68), minimum int, maximum int, config_value int, 
run_value int);
INSERT INTO #Options
EXECUTE sp_configure;
SELECT
       CASE
       WHEN EXISTS (SELECT
                           *
                      FROM #Options
                    WHERE
                          name LIKE 'default trace enabled'
                      AND run_value = 1) THEN 'Enabled'
           ELSE 'disabled'
       END;