# Per Server Monitoring Scripts

These scripts are meant for use with data collectors, and plugs a few gaps in the information provided by pre-built system data collectors.

# diskSpaceUsage.sql
Queries file and disk space related DMV's, returning a table that provides information for each file on the server, including which disk the file resides on and space remaining on that disk. Primary purpose is to monitor physical disk space availability for each file, checking to make sure that autogrow enabled files don't exhaust disk space or reach it's preset maximum size.

| Column        | Description                                                                               | 
| ------------- |:-----------------------------------------------------------------------------------------:|
| database_id   | id number of database on that server (unique per server)                                  |
| file_id       | file id number (unique per database)                                                      |
| data_space_id | unique per database -> uniquely identifies a tablespace or log file space within a database |
| type          | type of file -> ROWS stores tables and indexes, LOG stores transaction log                |
| state         | online/offline status of file                                                             |
| logical_volume_name | the name of the logical volume (disk) which contains the file                       |
| volume_mount_point | the mount point or drive letter of the volume which contains the file                |
| physical_name | path of the file                                                                          |
| FileSizeMB    | size of the file, in megabytes                                                            |
| OSUsedSpaceMB | total used megabytes of the volume on which the specified file is located                 |
| FreeSpaceMB   | free space remaining in the volume on which the specified file is located if autogrow is unrestricted, the lesser of maximum file size or free space on volume otherwise.                 |
| autoGrowthMB  | autogrowth increment of the file, 0 if autogrowth is disabled                             |

diskSpaceUsageInstall.sql will install a data collector set on the chosen server that snapshot this query, pushing it to [custom_snapshots].[disk_free_space_by_file] in a management data warehouse. 

Required Parameters: 
     @proxy = 'SQL Agent Execution Proxy';
    

# CPUUtilization.sql

Queries ring buffer to collect CPU usage for the previous 15 minutes (data source provides CPU Usage Information per minute).  CPUUtilizationInstall.sql will install a data collector set on the chosen server that snapshots this query once every 15 minutes, pushing it to [custom_snapshots].[cpu_usage_records] in a management data warehouse.

| Column        | Description                                                                               | 
| ------------- |:-----------------------------------------------------------------------------------------:|
| SQLServerProcessCPU   | Average CPU Usage (prior 15 minutes) by the SQL Server process                                |
| MaxSQLServerProcessCPU       | Average CPU Usage (prior 15 minutes) by the SQL Server process               |
| OtherProcessCPU | Average CPU Usage of other processes (over prior 15 minutes), taken as 100-SystemIdle-SQLServerProcessCPU  |
| MaxOtherProcessCPU          | Average CPU Usage of other processes                |
| SystemIdle          | Average CPU Idle Capacity (over prior 15 minutes)             |

Required Parameters: 
     @proxy = 'SQL Agent Execution Proxy';
