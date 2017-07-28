DECLARE @proxy NVARCHAR(max) = N'datacollectorprox'
DECLARE @system_stats nvarchar(max) = N'WITH innr AS (
select 
DB_NAME() as [database],
i.data_space_id [filegroup],
(CONVERT(BIGINT,a.used_pages / 128)) as [sizeMB],
(CASE WHEN u.user_scans IS NULL THEN 0 ELSE u.user_scans END) [scans],
(CASE WHEN u.user_lookups IS NULL THEN 0 ELSE u.user_lookups END) [lookups],
(CASE WHEN u.user_seeks IS NULL THEN 0 ELSE u.user_seeks END) [seeks],
(CASE WHEN u.user_updates IS NULL THEN 0 ELSE u.user_updates END) [writes]
from sys.indexes i 
		 join sys.partitions pr on pr.object_id = i.object_id and pr.index_id = i.index_id
		 join sys.allocation_units a on pr.partition_id = a.container_id
		 left join sys.dm_db_index_usage_stats u
		 on i.object_id = u.object_id and u.database_id = DB_ID() and u.index_id = i.index_id
)
SELECT [database],[filegroup],
sum([sizeMB]) as [sizeMB],sum([scans]) as [scans],sum(lookups) as lookups, sum(seeks) as seeks, sum(writes) as writes FROM innr
GROUP BY [database],[filegroup]'

DECLARE @database_stats nvarchar(max) = '
<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>
SET NOCOUNT ON;
'
+ @system_stats +'
</Value><OutputTable>tempdb_usage_stats</OutputTable></Query><Databases><Database>tempdb</Database></Databases></ns:TSQLQueryCollector>'

Begin Transaction
Begin Try
Declare @collection_set_id_31 int
Declare @collection_set_uid_32 uniqueidentifier
EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] @name=N'TempDB Aggregate Index Statistics', @collection_mode=0, @description=N'Collects diagnostic information on tempdb index structures', @logging_level=0, @days_until_expiration=60, @proxy_name=@proxy, @schedule_name=N'CollectorSchedule_Every_5min', @collection_set_id=@collection_set_id_31 OUTPUT, @collection_set_uid=@collection_set_uid_32 OUTPUT
Select @collection_set_id_31, @collection_set_uid_32

Declare @collector_type_uid_33 uniqueidentifier
Select @collector_type_uid_33 = collector_type_uid From [msdb].[dbo].[syscollector_collector_types] Where name = N'Generic T-SQL Query Collector Type';
Declare @collection_item_id_34 int
EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] @name=N'TempDB Aggregate Index Statistics - DMV Snapshots', @parameters=@database_stats, @collection_item_id=@collection_item_id_34 OUTPUT, @frequency=60, @collection_set_id=@collection_set_id_31, @collector_type_uid=@collector_type_uid_33; 
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
