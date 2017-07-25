DECLARE @system_stats nvarchar(max) = 'SELECT
 mf.database_id, 
 mf.file_id, 
 data_space_id, 
 type_desc as type, 
 state_desc as state ,
 dovs.volume_id , 
 dovs.logical_volume_name, 
 dovs.volume_mount_point ,
 mf.physical_name ,
CONVERT(BIGINT,mf.size / 128.0) as FileSizeMB,
CONVERT(BIGINT,dovs.total_bytes/1048576.0) AS OSUsedSpaceMB,
CONVERT(BIGINT,
(CASE 
    WHEN mf.max_size = 0 THEN mf.size * 128.0
	WHEN mf.max_size = -1 THEN dovs.available_bytes/1048576.0
	WHEN ((dovs.available_bytes/1048576.0) &gt; (mf.max_size / 128.0)) THEN mf.max_size / 128.0
	ELSE dovs.available_bytes/1048576.0
END)) AS FreeSpaceMB,
CONVERT(INT,(CASE 
    /* no growth allowed */
    WHEN mf.max_size = 0 THEN 0
	WHEN mf.max_size &lt;&gt; 0 AND mf.is_percent_growth = 0 THEN mf.growth / 128.0
	WHEN mf.max_size &lt;&gt; 0 AND mf.is_percent_growth = 1 THEN ( mf.growth * mf.size / 12800.0 ) 
	ELSE 2
END)) AS autoGrowthMB
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs'

DECLARE @database_stats nvarchar(max) = '
<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>
SET NOCOUNT ON
'
+ @system_stats +'
</Value><OutputTable>disk_free_space_by_file</OutputTable></Query></ns:TSQLQueryCollector>'

Begin Transaction
Begin Try
Declare @collection_set_id_31 int
Declare @collection_set_uid_32 uniqueidentifier
EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] @name=N'Disk Space Data', @collection_mode=0, @description=N'Collects diagnostic information about phyical disk remaining by files', @logging_level=0, @days_until_expiration=14, @proxy_name=N'datacollectorprox', @schedule_name=N'CollectorSchedule_Every_15min', @collection_set_id=@collection_set_id_31 OUTPUT, @collection_set_uid=@collection_set_uid_32 OUTPUT
Select @collection_set_id_31, @collection_set_uid_32

Declare @collector_type_uid_33 uniqueidentifier
Select @collector_type_uid_33 = collector_type_uid From [msdb].[dbo].[syscollector_collector_types] Where name = N'Generic T-SQL Query Collector Type';
Declare @collection_item_id_34 int
EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] @name=N'Disk Space Data - DMV Snapshots', @parameters=@database_stats, @collection_item_id=@collection_item_id_34 OUTPUT, @frequency=60, @collection_set_id=@collection_set_id_31, @collector_type_uid=@collector_type_uid_33; 
Commit Transaction;
End Try
Begin Catch
Rollback Transaction;
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @ErrorNumber INT;
DECLARE @ErrorLine INT;
DECLARE @ErrorProcedure NVARCHAR(200);
SELECT @ErrorLine = ERROR_LINE(),
       @ErrorSeverity = ERROR_SEVERITY(),
       @ErrorState = ERROR_STATE(),
       @ErrorNumber = ERROR_NUMBER(),
       @ErrorMessage = ERROR_MESSAGE(),
       @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');
RAISERROR (14684, @ErrorSeverity, 1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage);

End Catch;

GO