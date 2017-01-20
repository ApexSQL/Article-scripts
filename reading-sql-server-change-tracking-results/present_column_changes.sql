SELECT
ChVer = SYS_CHANGE_VERSION,
ChCrVer = SYS_CHANGE_CREATION_VERSION,
ChOp = SYS_CHANGE_OPERATION,
AddLine1_Changed = CHANGE_TRACKING_IS_COLUMN_IN_MASK
    (COLUMNPROPERTY(OBJECT_ID('Person.Address'), 'AddressLine1', 'ColumnId')
    ,ChTbl.sys_change_columns),
AddLine2_Changed = CHANGE_TRACKING_IS_COLUMN_IN_MASK
    (COLUMNPROPERTY(OBJECT_ID('Person.Address'), 'AddressLine2', 'ColumnId')
    ,ChTbl.sys_change_columns),
AddressID
FROM CHANGETABLE(CHANGES Person.Address, 1) AS ChTbl;