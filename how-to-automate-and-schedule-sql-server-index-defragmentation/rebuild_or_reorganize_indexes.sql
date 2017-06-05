USE <databasename>
SET NOCOUNT ON

DECLARE @reorg_frag_thresh   float		SET @reorg_frag_thresh   = 10.0
DECLARE @rebuild_frag_thresh float		SET @rebuild_frag_thresh = 30.0
DECLARE @fill_factor         tinyint	SET @fill_factor         = 80
DECLARE @report_only         bit			SET @report_only         = 1

-- added (DS) : page_count_thresh is used to check how many pages the current table uses
DECLARE @page_count_thresh	 smallint	SET @page_count_thresh   = 1000
 
-- Variables required for processing.
DECLARE @objectid       int
DECLARE @indexid        int
DECLARE @partitioncount bigint
DECLARE @schemaname     nvarchar(130) 
DECLARE @objectname     nvarchar(130) 
DECLARE @indexname      nvarchar(130) 
DECLARE @partitionnum   bigint
DECLARE @partitions     bigint
DECLARE @frag           float
DECLARE @page_count     int
DECLARE @command        nvarchar(4000)
DECLARE @intentions     nvarchar(4000)
DECLARE @table_var      TABLE(
                          objectid     int,
                          indexid      int,
                          partitionnum int,
                          frag         float,
								  page_count   int
                        )
 
-- Conditionally select tables and indexes from the
-- sys.dm_db_index_physical_stats function and
-- convert object and index IDs to names.
INSERT INTO
    @table_var
SELECT
    [object_id]                    AS objectid,
    [index_id]                     AS indexid,
    [partition_number]             AS partitionnum,
    [avg_fragmentation_in_percent] AS frag,
	[page_count]				   AS page_count
FROM
    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, 'LIMITED')
WHERE
    [avg_fragmentation_in_percent] > @reorg_frag_thresh 
	AND
	page_count > @page_count_thresh
	AND
    index_id > 0
	
 
-- Declare the cursor for the list of partitions to be processed.
DECLARE partitions CURSOR FOR
    SELECT * FROM @table_var
 
-- Open the cursor.
OPEN partitions
 
-- Loop through the partitions.
WHILE (1=1) BEGIN
    FETCH NEXT
        FROM partitions
        INTO @objectid, @indexid, @partitionnum, @frag, @page_count
 
    IF @@FETCH_STATUS < 0 BREAK
 
    SELECT
        @objectname = QUOTENAME(o.[name]),
        @schemaname = QUOTENAME(s.[name])
    FROM
        sys.objects AS o WITH (NOLOCK)
        JOIN sys.schemas as s WITH (NOLOCK)
        ON s.[schema_id] = o.[schema_id]
    WHERE
        o.[object_id] = @objectid
 
    SELECT
        @indexname = QUOTENAME([name])
    FROM
        sys.indexes WITH (NOLOCK)
    WHERE
        [object_id] = @objectid AND
        [index_id] = @indexid
 
    SELECT
        @partitioncount = count (*)
    FROM
        sys.partitions WITH (NOLOCK)
    WHERE
        [object_id] = @objectid AND
        [index_id] = @indexid
 
    -- Build the required statement dynamically based on options and index stats.
    SET @intentions =
        @schemaname + N'.' +
        @objectname + N'.' +
        @indexname + N':' + CHAR(13) + CHAR(10)
    SET @intentions =
        REPLACE(SPACE(LEN(@intentions)), ' ', '=') + CHAR(13) + CHAR(10) +
        @intentions
    SET @intentions = @intentions +
        N' FRAGMENTATION: ' + CAST(@frag AS nvarchar) + N'%' + CHAR(13) + CHAR(10) +
        N' PAGE COUNT: '    + CAST(@page_count AS nvarchar) + CHAR(13) + CHAR(10)
 
    IF @frag < @rebuild_frag_thresh BEGIN
        SET @intentions = @intentions +
            N' OPERATION: REORGANIZE' + CHAR(13) + CHAR(10)
        SET @command =
            N'ALTER INDEX ' + @indexname +
            N' ON ' + @schemaname + N'.' + @objectname +
            N' REORGANIZE; ' + 
            N' UPDATE STATISTICS ' + @schemaname + N'.' + @objectname + 
            N' ' + @indexname + ';'

    END
    IF @frag >= @rebuild_frag_thresh BEGIN
        SET @intentions = @intentions +
            N' OPERATION: REBUILD' + CHAR(13) + CHAR(10)
        SET @command =
            N'ALTER INDEX ' + @indexname +
            N' ON ' + @schemaname + N'.' +     @objectname +
            N' REBUILD'
    END
    IF @partitioncount > 1 BEGIN
        SET @intentions = @intentions +
            N' PARTITION: ' + CAST(@partitionnum AS nvarchar(10)) + CHAR(13) + CHAR(10)
        SET @command = @command +
            N' PARTITION=' + CAST(@partitionnum AS nvarchar(10))
    END
    IF @frag >= @rebuild_frag_thresh AND @fill_factor > 0 AND @fill_factor < 100 BEGIN
        SET @intentions = @intentions +
            N' FILL FACTOR: ' + CAST(@fill_factor AS nvarchar) + CHAR(13) + CHAR(10)
        SET @command = @command +
            N' WITH (FILLFACTOR = ' + CAST(@fill_factor AS nvarchar) + ')'
    END
 
    -- Execute determined operation, or report intentions
    IF @report_only = 0 BEGIN
        SET @intentions = @intentions + N' EXECUTING: ' + @command
        PRINT @intentions	    
        EXEC (@command)
    END ELSE BEGIN
        PRINT @intentions
    END
	PRINT @command

END
 
-- Close and deallocate the cursor.
CLOSE partitions
DEALLOCATE partitions
 
GO
