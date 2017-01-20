SELECT event_time,action_id,statement,database_name,server_principal_name
  FROM fn_get_audit_file( 'E:\Test\Audit-*.sqlaudit' , DEFAULT , DEFAULT);
      