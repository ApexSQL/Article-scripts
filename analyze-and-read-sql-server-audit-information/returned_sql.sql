UPDATE TOP (200) Person.AddressType SET NAME = @Name WHERE (AddressTypeID = @Param1) AND 
(NAME = @Param2) AND (rowguid = @Param3) AND (ModifiedDate = @Param4)