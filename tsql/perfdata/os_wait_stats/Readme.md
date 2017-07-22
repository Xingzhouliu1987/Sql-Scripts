# OS Wait Stats From Server Activity Data Collector

With the Server Activity Data Collector enabled on an instance, it will start collecting several snapshots, one of which is snapshots of the *sys.dm_os_wait_stats* view. This view holds the aggregate counter values since prior server start. This query builds deltas in counter values between two collections.

The data collector job is configured to upload collected data to a designated management data warehouse. These snapshots are available in table snapshots.os_wait_stats in management database.

Wait type 13: Idle is excluded intentionally.

## Why Collector Sets?

Shipping 2008 and up, data collector sets are a convenient way to collect and manage both SQL Server and Windows performance and troubleshooting information. They work by snapshotting certain system dynamic management views, which contain information about both the system and SQL Server. This snapshotting is done through simple, automatically generated jobs.

Configurations include frequency, where to ship the information and how often, and how long is certain data kept. Busy servers could generate serveral hundred megs per day. 

In addition to tsql stored procedures, Collector Sets use SSIS to load the data into a MDW, against which SSRS and SSAS functionality can be applied.

Built in collectors cover most high priority metrics, such as query execution, waits, system resource counters, throughput. 

Custom collectors can be built using .Net.


