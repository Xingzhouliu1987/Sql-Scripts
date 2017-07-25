# Per Server Monitoring Scripts


# diskSpaceUsage.sql
Queries file and disk space related DMV's, returning a table that provides information for each file on the server, including which disk the file resides on and space remaining on that disk. Primary purpose is to monitor physical disk space availability for each file, checking to make sure that autogrow enabled files don't exhaust disk space.

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
| FreeSpaceMB   | free space remaining in the volume on which the specified file is located                 |
| autoGrowthMB  | autogrowth increment of the file, 0 if autogrowth is disabled                             |

diskSpaceUsageInstall.sql will install a data collector set on the chosen server that snapshot this query.
