/****** Script for SelectTopNRows command from SSMS  ******/
create view delta_wait_stats AS
select 
t.category_id,
snapshot_id,
w.wait_type,
collection_time,
wait_time_ms, 
signal_wait_time_ms,
delta_time = -DATEDIFF(MILLISECOND,collection_time, coalesce( lag(collection_time,1) over (partition by w.wait_type order by w.wait_type,collection_time), collection_time) ),
delta_wait_time_ms =wait_time_ms- coalesce( lag(wait_time_ms,1) over (partition by w.wait_type order by w.wait_type,collection_time), 0),
delta_signal_wait_time_ms = signal_wait_time_ms - coalesce( lag(signal_wait_time_ms,1) over (partition by w.wait_type order by w.wait_type,collection_time) , 0),
current_queue = waiting_tasks_count - coalesce( lag(waiting_tasks_count,1) over (partition by w.wait_type order by w.wait_type,collection_time) , 0),
waiting_tasks_count
from snapshots.os_wait_stats w
JOIN core.wait_types t ON w.wait_type = t.wait_type
join core.wait_categories c ON t.category_id = c.category_id
AND t.category_id <> 13
/* order by w.wait_type,snapshot_id,collection_time ; */

