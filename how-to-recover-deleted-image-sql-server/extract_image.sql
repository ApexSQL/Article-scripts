sp_configure 'Ole Automation Procedures' ,1
GO
RECONFIGURE
GO

DECLARE @token int,
          @image varbinary(max),
          @file varchar(50)

   SELECT @image = ImageData, @file= ExtractPath FROM ImagesStore WHERE
   ImageId = 1

   EXEC sp_OACreate 'ADODB.Stream', @token OUTPUT 
   EXEC sp_OASetProperty @token, 'Type', 1
   EXEC sp_OAMethod @token, 'Open'
   EXEC sp_OAMethod @token, 'Write',   NULL,@image
   EXEC sp_OAMethod @token, 'SaveToFile', NULL, @file , 2
   EXEC sp_OAMethod @token, 'Close'
   EXEC sp_OADestroy @token