CREATE TABLE DDL_Audit_Events
(
             DDL_Event_Time            datetime
             ,
             DDL_Login_Name            varchar(250)
             ,
             DDL_Database_Name         varchar(250)
             ,
             DDL_Object_Name           varchar(250)
             ,
             DDL_Command              varchar(max)
);