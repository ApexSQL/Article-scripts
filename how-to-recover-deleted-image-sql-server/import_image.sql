INSERT INTO ImagesStore
SELECT 'C:\Users\Public\Pictures\Sample Pictures', BulkColumn 
FROM OPENROWSET( BULK 'C:\Users\Public\Pictures\Sample Pictures\Penguins.jpg',
Single_Blob) as ImageData