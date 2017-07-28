DECLARE @proxy NVARCHAR(max) = N'datacollectorprox'
DECLARE @system_stats nvarchar(max) = N'select 
DB_NAME() as [database],
OBJECT_SCHEMA_NAME(i.object_id) AS [schema],
OBJECT_NAME(i.object_id) AS [table],
i.name as [index],
i.type_desc as [index_type],
pr.partition_number,
pr.partition_id [partition],
fg.data_space_id [filegroup],
record_count,
i.fill_factor,
CONVERT(BIGINT,a.used_pages / 128) as [sizeMB],
p.avg_fragmentation_in_percent [internal_fragmentation],
100 - p.avg_page_space_used_in_percent [external_fragmentation],
u.user_scans [scans],
u.user_lookups [lookups],
u.user_seeks [seek],
u.user_updates [writes]
from sys.indexes i 
         cross apply sys.dm_db_index_physical_stats(DB_ID(),i.object_id, i.index_id, 0, ''SAMPLED'') p
		 left join sys.partitions pr on pr.object_id = p.object_id and pr.index_id = p.index_id and p.partition_number = pr.partition_number
		 left join sys.allocation_units a on pr.partition_id = a.container_id
		 left join sys.dm_db_index_usage_stats u
		 on i.object_id = u.object_id and u.database_id = DB_ID() and u.index_id = i.index_id
		 left join sys.filegroups fg on fg.data_space_id = i.data_space_id'

DECLARE @database_stats nvarchar(max) = '
<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>
SET NOCOUNT ON
'
+ @system_stats +'
</Value><OutputTable>index_statistics</OutputTable></Query><Databases UseUserDatabases="true" /></ns:TSQLQueryCollector>'

Begin Transaction
Begin Try
Declare @collection_set_id_31 int
Declare @collection_set_uid_32 uniqueidentifier
EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] @name=N'Index Statistics', @collection_mode=0, @description=N'Collects diagnostic information on index structures', @logging_level=0, @days_until_expiration=60, @proxy_name=@proxy, @schedule_name=N'CollectorSchedule_Every_30min', @collection_set_id=@collection_set_id_31 OUTPUT, @collection_set_uid=@collection_set_uid_32 OUTPUT
Select @collection_set_id_31, @collection_set_uid_32

Declare @collector_type_uid_33 uniqueidentifier
Select @collector_type_uid_33 = collector_type_uid From [msdb].[dbo].[syscollector_collector_types] Where name = N'Generic T-SQL Query Collector Type';
Declare @collection_item_id_34 int
EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] @name=N'Index Statistics - DMV Snapshots', @parameters=@database_stats, @collection_item_id=@collection_item_id_34 OUTPUT, @frequency=60, @collection_set_id=@collection_set_id_31, @collector_type_uid=@collector_type_uid_33; 
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
