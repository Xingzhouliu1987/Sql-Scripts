drop table dbo.perfmon_snapshots;
go

create table dbo.perfmon_snapshots (
   object_name nvarchar(64) not null,
   counter_name nvarchar(128) not null,
   instance_name nvarchar(128) not null,
   cntr_value bigint not null,
   cntr_type bigint not null ,
   snapshot_id bigint not null ,
   snapshot_time datetime not null
   constraint perfmon_snaps_pk primary key clustered (
		snapshot_id,
		object_name,
		counter_name,
		instance_name
   )
)
go

create sequence dbo.perfmon_snaps;
go
create procedure dbo.snapshot_perfmon
as 
 begin
   DECLARE @time datetime = GETDATE ()
   DECLARE @sequence bigint;
   set @sequence = NEXT VALUE FOR dbo.perfmon_snaps;
   INSERT dbo.perfmon_snapshots
   select 
   object_name,
   counter_name,
   instance_name,
   cntr_value,
   cntr_type,
   snapshot_id = @sequence ,
   snapshot_time = @time
   from sys.dm_os_performance_counters;
 end

