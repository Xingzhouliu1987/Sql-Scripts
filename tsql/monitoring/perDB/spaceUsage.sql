
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'adminTools')
    EXEC('CREATE SCHEMA adminTools');
GO
IF OBJECT_ID('adminTools.spaceUsageVW') IS NOT NULL
   DROP VIEW adminTools.spaceUsageVW;
GO
CREATE VIEW adminTools.spaceUsageVW
AS
select 
    s.Name AS SchemaName,
    t.NAME AS TableName,
	i.name AS IndexName,
	p.partition_id AS partition_id ,
	i.index_id,
    p.rows AS RowCounts,
	files.volume_mount_point ,
	files.physical_name ,
	files.data_space_id ,
    CONVERT(BIGINT,(SUM(a.total_pages) * 8) / 1024.00) AS TotalSpaceMB,
    CONVERT(BIGINT,(SUM(a.used_pages) * 8) / 1024.00) AS UsedSpaceMB, 
    CONVERT(BIGINT,((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00) AS UnusedSpaceMB,
	SUM(files.FileSizeMB) as FileSizeMB,
	MIN(files.FreeSpaceMB) as FreeSpaceMB,
	MIN(files.OSUsedSpaceMB) as OSUsedSpaceMB,
	SUM(files.auto_growth_setting) as auto_growth_setting
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
LEFT OUTER JOIN master.adminTools.diskFreeSpaceFN(DB_ID()) files
ON a.data_space_id = files.data_space_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
	GROUP BY 
    t.Name, s.Name, i.name, i.index_id , p.Rows , p.partition_id , files.volume_mount_point, files.physical_name , files.data_space_id 

select * from adminTools.spaceUsageVW