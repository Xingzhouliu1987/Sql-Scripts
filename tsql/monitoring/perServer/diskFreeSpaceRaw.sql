SELECT DISTINCT
 mf.database_id, 
 mf.file_id, 
 data_space_id, 
 type_desc as type, 
 state_desc as state ,
 dovs.volume_id , 
 dovs.logical_volume_name, 
 dovs.volume_mount_point ,
 mf.physical_name ,
CONVERT(BIGINT,mf.size / 128.0) as FileSizeMB,
CONVERT(BIGINT,dovs.total_bytes/1048576.0) AS OSUsedSpaceMB,
CONVERT(BIGINT,
(CASE 
   /* no growth allowed */
    WHEN mf.max_size = 0 THEN mf.size * 128.0
   /* unrestricted growth */	
	WHEN mf.max_size = -1 THEN dovs.available_bytes/1048576.0
   /* page count restricted growth - lesser of  total available space or max size pages */
	WHEN ((dovs.available_bytes/1048576.0) > (mf.max_size / 128.0)) THEN mf.max_size / 128.0
	ELSE dovs.available_bytes/1048576.0
END)) AS FreeSpaceMB,
CONVERT(INT,(CASE 
    /* no growth allowed */
    WHEN mf.max_size = 0 THEN 0
	WHEN mf.max_size <> 0 AND mf.is_percent_growth = 0 THEN mf.growth / 128.0
	WHEN mf.max_size <> 0 AND mf.is_percent_growth = 1 THEN ( mf.growth * mf.size / 12800.0 ) 
	ELSE 2
END)) AS auto_growth_setting
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
