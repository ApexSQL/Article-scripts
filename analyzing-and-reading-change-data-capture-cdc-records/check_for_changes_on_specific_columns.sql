DECLARE @from_lsn binary (10) ,@to_lsn binary (10)
DECLARE @AddressIDPosition INT
DECLARE @AddressLine1Position INT
DECLARE @AddressLine2Position INT
DECLARE @CityPosition INT
DECLARE @StProvIDPos INT
DECLARE @PostalCode INT

SET @from_lsn = sys.fn_cdc_get_min_lsn('Person_Address')
SET @to_lsn = sys.fn_cdc_get_max_lsn()
SET @AddressIDPosition = sys.fn_cdc_get_column_ordinal('Person_Address', 
'AddressID')
SET @AddressLine1Position = sys.fn_cdc_get_column_ordinal('Person_Address', 
'AddressLine1')
SET @AddressLine2Position = sys.fn_cdc_get_column_ordinal('Person_Address', 
'AddressLine2')
SET @CityPosition = sys.fn_cdc_get_column_ordinal('Person_Address', 'City')
SET @StProvIDPos = sys.fn_cdc_get_column_ordinal('Person_Address', 
'StateProvinceID')
SET @PostalCode = sys.fn_cdc_get_column_ordinal('Person_Address', 'PostalCode')

SELECT fn_cdc_get_all_changes_Person_Address.__$operation
	,fn_cdc_get_all_changes_Person_Address.__$update_mask
	,sys.fn_cdc_is_bit_set(@AddressIDPosition, __$update_mask) as 
'UpdatedAddressID'
	,sys.fn_cdc_is_bit_set(@AddressLine1Position, __$update_mask) as 
'UpdatedLine1'
	,sys.fn_cdc_is_bit_set(@AddressLine2Position, __$update_mask) as 
'UpdatedLine2'
	,sys.fn_cdc_is_bit_set(@CityPosition fn_cdc_get_column_ordinal) as 
'UpdatedCity'
	,sys.fn_cdc_is_bit_set(@StProvIDPos, __$update_mask) as 
'UpdatedState'
	,sys.fn_cdc_is_bit_set(@PostalCode, __$update_mask) as 'Updated Postal'
FROM cdc.fn_cdc_get_all_changes_Person_Address(@from_lsn, @to_lsn, 'all')
ORDER BY __$seqval