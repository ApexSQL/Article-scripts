CREATE TABLE Audit_DDL_Events
(
             DDL_Event_Time            datetime
             ,
             DDL_Login_Name            varchar(150)
             ,
             DDL_User_Name             varchar(150)
             ,
             DDL_Database_Name         varchar(150)
             ,
             DDL_Schema_Name           varchar(150)
             ,
             DDL_Object_Name           varchar(150)
             ,
             DDL_Object_Type           varchar(150)
             ,
             DDL_Command              varchar(max)
);