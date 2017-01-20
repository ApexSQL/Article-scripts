SELECT type_desc
	,total_count = COUNT(*)
	,last_create_date = MAX(create_date)
	,last_modify_date = MAX(modify_date)
FROM sys.objects
WHERE sys.objects.type NOT IN (
		'C'
		,'D'
		,'F'
		,'UQ'
		)
GROUP BY type_desc