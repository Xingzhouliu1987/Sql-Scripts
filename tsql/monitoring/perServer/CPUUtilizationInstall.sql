/******
     Source: https://social.msdn.microsoft.com/Forums/sqlserver/en-US/38f34421-60b8-4bf4-b779-56e2f1d70cc0/how-to-check-cpu-usage-by-sql?forum=sqldatabaseengine 
	 When Debugging Data collectors, look at job history and not data collector log!
******/
DECLARE @proxy NVARCHAR(max) = N'datacollectorprox'
DECLARE @querystring NVARCHAR(MAX) = N'SET NOCOUNT ON;
WITH CTE AS (
/* past 15 minutes */
SELECT TOP(15) SQLProcessUtilization, 
               SystemIdle, 
               (100 - SystemIdle - SQLProcessUtilization) AS OtherCPU
FROM ( 
	  SELECT record.value(''(./Record/@id)[1]'', ''int'') AS record_id, 
			record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') 
			AS [SystemIdle], 
			record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', 
			''int'') 
			AS [SQLProcessUtilization]
	  FROM ( 
			SELECT CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers 
			WHERE ring_buffer_type = N''RING_BUFFER_SCHEDULER_MONITOR'' 
			AND record LIKE ''%SystemHealth%'') AS x 
	  ) AS y 
ORDER BY record_id DESC 
)
SELECT AVG([SQLProcessUtilization]) as [SQLServerProcessCPU],
       MAX([SQLProcessUtilization]) as [MaxSQLServerProcessCPU],
       AVG([SystemIdle]) AS [SystemIdleProcess],
	   AVG([OtherCPU]) AS [OtherProcessCPU],
	   MAX([OtherCPU]) AS [MaxOtherProcessCPU]
	   FROM CTE OPTION (RECOMPILE)';
exec sp_executesql @querystring;
DECLARE @database_stats nvarchar(max) = '<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>
SET NOCOUNT ON
'
+ @querystring +'
</Value><OutputTable>cpu_usage_record</OutputTable></Query></ns:TSQLQueryCollector>'

Begin Transaction
Begin Try
Declare @collection_set_id_31 int
Declare @collection_set_uid_32 uniqueidentifier
EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] @name=N'CPU Usage', @collection_mode=0, @description=N'Collects 15 minute snapshots of average and max cpu utilization', @logging_level=0, @days_until_expiration=14, @proxy_name=@proxy, @schedule_name=N'CollectorSchedule_Every_15min', @collection_set_id=@collection_set_id_31 OUTPUT, @collection_set_uid=@collection_set_uid_32 OUTPUT
Select @collection_set_id_31, @collection_set_uid_32

Declare @collector_type_uid_33 uniqueidentifier
Select @collector_type_uid_33 = collector_type_uid From [msdb].[dbo].[syscollector_collector_types] Where name = N'Generic T-SQL Query Collector Type';
Declare @collection_item_id_34 int
EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] @name=N'CPU Usage - Snapshots', @parameters=@database_stats, @collection_item_id=@collection_item_id_34 OUTPUT, @frequency=60, @collection_set_id=@collection_set_id_31, @collector_type_uid=@collector_type_uid_33; 
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