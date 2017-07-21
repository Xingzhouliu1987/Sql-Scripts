# OS Wait Stats From Server Activity Data Collector

With the Server Activity Data Collector enabled on an instance, it will start collecting several snapshots, one of which is snapshots of the *sys.dm_os_wait_stats* view. This view holds the aggregate counter values since prior server start. This query builds deltas in counter values between two collections.

The data collector job is configured to upload collected data to a designated management data warehouse. These snapshots are available in table snapshots.os_wait_stats in management database.

Wait type 13: Idle is excluded intentionally.
