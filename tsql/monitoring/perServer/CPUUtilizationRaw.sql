/******
     Source: https://social.msdn.microsoft.com/Forums/sqlserver/en-US/38f34421-60b8-4bf4-b779-56e2f1d70cc0/how-to-check-cpu-usage-by-sql?forum=sqldatabaseengine 
	 
******/
WITH CTE AS (
SELECT TOP(256) SQLProcessUtilization, 
               SystemIdle, 
               (100 - SystemIdle - SQLProcessUtilization) AS OtherCPU
FROM ( 
	  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
			'int') 
			AS [SQLProcessUtilization]
	  FROM ( 
			SELECT CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers 
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE '%<SystemHealth>%') AS x 
	  ) AS y 
ORDER BY record_id DESC 
)
SELECT AVG([SQLProcessUtilization]) as [SQLServerProcessCPU],
       MAX([SQLProcessUtilization]) as [MaxSQLServerProcessCPU],
       AVG([SystemIdle]) AS [SystemIdleProcess],
	   AVG([OtherCPU]) AS [OtherProcessCPU],
	   MAX([OtherCPU]) AS [MaxOtherProcessCPU]
	   FROM CTE OPTION (RECOMPILE)
