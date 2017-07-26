IF OBJECT_ID('dbo.adminHelperPartitionObjectMatch') IS NOT NULL
   DROP VIEW dbo.adminHelperPartitionObjectMatch;
GO

CREATE VIEW dbo.adminHelperPartitionObjectMatch AS
     SELECT OBJECT_NAME(A.object_id) AS obj_name, A.object_id, B.partition_id , A.type, A.type_desc
	 FROM sys.objects A JOIN sys.partitions B ON A.object_id = B.object_id;
GO
select * from dbo.adminHelperPartitionObjectMatch
/*
	get user behind log record
*/
select suser_sname([Transaction SID]) as sid, count(*) opct 
       FROM fn_dblog(null,null) d
	   group by d.[Transaction SID] ORDER BY opct DESC;

select suser_sname([Transaction SID]) AS user_name,
		[Current LSN]  FROM fn_dblog(null,null) 
		where suser_sname([Transaction SID]) is not null;

/* 
    IDENTIFY minimally logged operations under bulk logged recovery model against user tables
*/
SELECT A.*, B.obj_name FROM fn_dblog(null,null) A JOIN dbo.adminHelperPartitionObjectMatch B 
ON a.PartitionId = b.partition_id
WHERE Operation = 'LOP_FORMAT_PAGE' AND B.type_desc = 'USER_TABLE'

/* 
    IDENTIFY operations against user tables
*/
SELECT A.*, B.obj_name FROM fn_dblog(null,null) A JOIN dbo.adminHelperPartitionObjectMatch B 
ON a.PartitionId = b.partition_id WHERE b.type_desc = 'USER_TABLE';

/* transaction log operations */
SELECT DISTINCT Operation FROM fn_dblog(null,null);

SELECT A.*, B.obj_name FROM fn_dblog(null,null) A JOIN dbo.adminHelperPartitionObjectMatch B 
ON a.PartitionId = b.partition_id 
join sys.dm_tran_database_transactions d on  d.transaction_id = A.[Transaction ID] WHERE b.type_desc = 'USER_TABLE';

