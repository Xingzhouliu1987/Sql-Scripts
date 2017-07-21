/****** Script for SelectTopNRows command from SSMS  ******/

select wait_type, snapshot_id, 
  avg(waiting_tasks_count) OVER (PARTITION BY wait_type ORDER BY snapshot_id) as qlength, 
  sum(wait_time_ms) OVER (PARTITION BY wait_type ORDER BY snapshot_id) as wait_time, 
  sum(signal_wait_time_ms) OVER (PARTITION BY wait_type ORDER BY snapshot_id) as cpuwait 
  from 
  (select wait_type, snapshot_id, 
  avg(waiting_tasks_count) as waiting_tasks_count, 
  sum(wait_time_ms) as wait_time_ms,
  sum(signal_wait_time_ms) as signal_wait_time_ms from snapshots.os_wait_stats
  group by wait_type, snapshot_id 
  ) as a

