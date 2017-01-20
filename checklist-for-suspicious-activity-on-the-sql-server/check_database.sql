SELECT NAME
	,create_date
	,user_access_desc
	,CASE is_read_only
		WHEN 1
			THEN 'Yes'
		WHEN 0
			THEN 'No'
		END AS is_read_only
	,state_desc
	,CASE is_in_standby
		WHEN 1
			THEN 'Yes'
		WHEN 0
			THEN 'No'
		END AS is_in_standby
	,CASE is_cleanly_shutdown
		WHEN 1
			THEN 'Yes'
		WHEN 0
			THEN 'No'
		END AS is_cleanly_shutdown
FROM sys.databases