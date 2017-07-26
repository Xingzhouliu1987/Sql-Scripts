USE [msdb];
GO
/*
   Source: https://www.sqlskills.com/blogs/glenn/the-accidental-dba-day-17-of-30-configuring-alerts-for-high-severity-problems/
   Installs alerts for high severity error conditions
*/
-- Make sure you have an Agent Operator defined
-- Change @OperatorName as needed
DECLARE @OperatorName sysname = N'XingLiu';

-- Change @CategoryName as needed
DECLARE @CategoryName sysname = N'SQL Server Agent Alerts';

-- Add Alert Category if it does not exist
IF NOT EXISTS (SELECT *
               FROM msdb.dbo.syscategories
               WHERE category_class = 2  -- ALERT
               AND category_type = 3
               AND name = @CategoryName)
    BEGIN
        EXEC dbo.sp_add_category @class = N'ALERT', @type = N'NONE', @name = @CategoryName;
    END

-- Get the server name
DECLARE @ServerName sysname = (SELECT @@SERVERNAME);

-- Alert Names start with the name of the server 
DECLARE @Sev19AlertName sysname = @ServerName + N' Alert - Sev 19 Error: Fatal Error in Resource';
DECLARE @Sev20AlertName sysname = @ServerName + N' Alert - Sev 20 Error: Fatal Error in Current Process';
DECLARE @Sev21AlertName sysname = @ServerName + N' Alert - Sev 21 Error: Fatal Error in Database Process';
DECLARE @Sev22AlertName sysname = @ServerName + N' Alert - Sev 22 Error Fatal Error: Table Integrity Suspect';
DECLARE @Sev23AlertName sysname = @ServerName + N' Alert - Sev 23 Error: Fatal Error Database Integrity Suspect';
DECLARE @Sev24AlertName sysname = @ServerName + N' Alert - Sev 24 Error: Fatal Hardware Error';
DECLARE @Sev25AlertName sysname = @ServerName + N' Alert - Sev 25 Error: Fatal Error';
DECLARE @Error825AlertName sysname = @ServerName + N' Alert - Error 825: Read-Retry Required';

-- Sev 19 Error: Fatal Error in Resource
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Sev19AlertName)
    EXEC msdb.dbo.sp_add_alert @name = @Sev19AlertName, 
                  @message_id=0, @severity=19, @enabled=1, 
                  @delay_between_responses=900, @include_event_description_in=1,
                  @category_name = @CategoryName, 
                  @job_id=N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
          FROM dbo.sysalerts AS sa
          INNER JOIN dbo.sysnotifications AS sn
          ON sa.id = sn.alert_id
          WHERE sa.name = @Sev19AlertName)
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Sev19AlertName, @operator_name=@OperatorName, @notification_method = 1;
    END

-- Sev 20 Error: Fatal Error in Current Process
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Sev20AlertName)
    EXEC msdb.dbo.sp_add_alert @name = @Sev20AlertName, 
                  @message_id=0, @severity=20, @enabled=1, 
                  @delay_between_responses=900, @include_event_description_in=1,
                  @category_name = @CategoryName, 
                  @job_id=N'00000000-0000-0000-0000-000000000000'

-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
          FROM dbo.sysalerts AS sa
          INNER JOIN dbo.sysnotifications AS sn
          ON sa.id = sn.alert_id
          WHERE sa.name = @Sev20AlertName)
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Sev20AlertName, @operator_name=@OperatorName, @notification_method = 1;
    END

-- Sev 21 Error: Fatal Error in Database Process
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Sev21AlertName)
    EXEC msdb.dbo.sp_add_alert @name = @Sev21AlertName, 
                  @message_id=0, @severity=21, @enabled=1, 
                  @delay_between_responses=900, @include_event_description_in=1,
                  @category_name = @CategoryName, 
                  @job_id=N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
          FROM dbo.sysalerts AS sa
          INNER JOIN dbo.sysnotifications AS sn
          ON sa.id = sn.alert_id
          WHERE sa.name = @Sev21AlertName)
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Sev21AlertName, @operator_name=@OperatorName, @notification_method = 1;
    END

-- Sev 22 Error: Fatal Error Table Integrity Suspect
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Sev22AlertName)
    EXEC msdb.dbo.sp_add_alert @name = @Sev22AlertName, 
                  @message_id=0, @severity=22, @enabled=1, 
                  @delay_between_responses=900, @include_event_description_in=1,
                  @category_name = @CategoryName, 
                  @job_id=N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
          FROM dbo.sysalerts AS sa
          INNER JOIN dbo.sysnotifications AS sn
          ON sa.id = sn.alert_id
          WHERE sa.name = @Sev22AlertName)
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Sev22AlertName, @operator_name=@OperatorName, @notification_method = 1;
    END

-- Sev 23 Error: Fatal Error Database Integrity Suspect
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Sev23AlertName)
    EXEC msdb.dbo.sp_add_alert @name = @Sev23AlertName, 
                  @message_id=0, @severity=23, @enabled=1, 
                  @delay_between_responses=900, @include_event_description_in=1,
                  @category_name = @CategoryName, 
                  @job_id=N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
          FROM dbo.sysalerts AS sa
          INNER JOIN dbo.sysnotifications AS sn
          ON sa.id = sn.alert_id
          WHERE sa.name = @Sev23AlertName)
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Sev23AlertName, @operator_name = @OperatorName, @notification_method = 1;
    END

-- Sev 24 Error: Fatal Hardware Error
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Sev24AlertName)
    EXEC msdb.dbo.sp_add_alert @name = @Sev24AlertName, 
                  @message_id=0, @severity=24, @enabled=1, 
                  @delay_between_responses=900, @include_event_description_in=1,
                  @category_name = @CategoryName, 
                  @job_id=N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
          FROM dbo.sysalerts AS sa
          INNER JOIN dbo.sysnotifications AS sn
          ON sa.id = sn.alert_id
          WHERE sa.name = @Sev24AlertName)
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Sev24AlertName, @operator_name = @OperatorName, @notification_method = 1;
    END

-- Sev 25 Error: Fatal Error
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Sev25AlertName)
    EXEC msdb.dbo.sp_add_alert @name = @Sev25AlertName, 
                  @message_id=0, @severity=25, @enabled=1, 
                  @delay_between_responses=900, @include_event_description_in=1, 
                  @category_name = @CategoryName,
                  @job_id=N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
          FROM dbo.sysalerts AS sa
          INNER JOIN dbo.sysnotifications AS sn
          ON sa.id = sn.alert_id
          WHERE sa.name = @Sev25AlertName)
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Sev25AlertName, @operator_name = @OperatorName, @notification_method = 1;
    END

-- Error 825: Read-Retry Required
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Error825AlertName)
    EXEC msdb.dbo.sp_add_alert @name = @Error825AlertName, 
                  @message_id=825, @severity=0, @enabled=1, 
                  @delay_between_responses=900, @include_event_description_in=1, 
                  @category_name = @CategoryName, 
                  @job_id=N'00000000-0000-0000-0000-000000000000';


-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
          FROM dbo.sysalerts AS sa
          INNER JOIN dbo.sysnotifications AS sn
          ON sa.id = sn.alert_id
          WHERE sa.name = @Error825AlertName)
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Error825AlertName, @operator_name = @OperatorName, @notification_method = 1;
    END


DECLARE @Error832AlertName sysname = @ServerName + N' Alert - Error 832 - unexpected change on constant page. Check hardware then SQL Server Extensions';
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Error832AlertName)
    EXEC msdb.dbo.sp_add_alert @name = @Error832AlertName, 
                  @message_id=832, @severity=0, @enabled=1, 
                  @delay_between_responses=900, @include_event_description_in=1, 
                  @category_name = @CategoryName, 
                  @job_id=N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
          FROM dbo.sysalerts AS sa
          INNER JOIN dbo.sysnotifications AS sn
          ON sa.id = sn.alert_id
          WHERE sa.name = @Error832AlertName)
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Error832AlertName, @operator_name = @OperatorName, @notification_method = 1;
    END

DECLARE @Error855AlertName sysname = @ServerName + N' Alert - Error 855: Uncorrectable hardware memory corruption detected';
DECLARE @Error856AlertName sysname = @ServerName + N' Alert - Error 856: SQL Server has detected hardware memory corruption, but has recovered the page';

-- Check for SQL Server 2012 or greater and Enterprise Edition
-- You also need Windows Server 2012 or greater, plus hardware that supports memory error correction
IF LEFT(CONVERT(CHAR(2),SERVERPROPERTY('ProductVersion')), 2) >= '11' AND SERVERPROPERTY('EngineEdition') = 3
    BEGIN
        -- Error 855: Uncorrectable hardware memory corruption detected
		IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Error855AlertName)
			EXEC msdb.dbo.sp_add_alert @name = @Error855AlertName, 
						  @message_id = 855, @severity = 0, @enabled = 1, 
						  @delay_between_responses = 900, @include_event_description_in = 1, 
						  @category_name = @CategoryName, 
						  @job_id  = N'00000000-0000-0000-0000-000000000000';


		-- Add a notification if it does not exist
		IF NOT EXISTS(SELECT *
					  FROM dbo.sysalerts AS sa
					  INNER JOIN dbo.sysnotifications AS sn
					  ON sa.id = sn.alert_id
					  WHERE sa.name = @Error855AlertName)
			BEGIN
				EXEC msdb.dbo.sp_add_notification @alert_name = @Error855AlertName, @operator_name = @OperatorName, @notification_method = 1;
			END

		-- Error 856: SQL Server has detected hardware memory corruption, but has recovered the page
		-- Buffer Pool/Data Page not processing IO, SQL discards and decommits the in memory page
		IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Error856AlertName)
			EXEC msdb.dbo.sp_add_alert @name = @Error856AlertName, 
						  @message_id = 856, @severity = 0, @enabled = 1, 
						  @delay_between_responses = 900, @include_event_description_in = 1, 
						  @category_name = @CategoryName, 
						  @job_id  = N'00000000-0000-0000-0000-000000000000';


		-- Add a notification if it does not exist
		IF NOT EXISTS(SELECT *
					  FROM dbo.sysalerts AS sa
					  INNER JOIN dbo.sysnotifications AS sn
					  ON sa.id = sn.alert_id
					  WHERE sa.name = @Error856AlertName)
			BEGIN
				EXEC msdb.dbo.sp_add_notification @alert_name = @Error856AlertName, @operator_name = @OperatorName, @notification_method = 1;
			END
    END

DECLARE @Error823AlertName sysname = @ServerName + N' Alert - Error 823: The operating system returned an error';
DECLARE @Error824AlertName sysname = @ServerName + N' Alert - Error 824: Logical consistency-based I/O error';
-- Error 823: Operating System Error
-- How to troubleshoot a Msg 823 error in SQL Server	
-- http://support.microsoft.com/kb/2015755
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Error823AlertName)
	EXEC msdb.dbo.sp_add_alert @name = @Error823AlertName, 
				  @message_id = 823, @severity = 0, @enabled = 1, 
				  @delay_between_responses = 900, @include_event_description_in = 1, 
				  @category_name = @CategoryName, 
				  @job_id  = N'00000000-0000-0000-0000-000000000000';


-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
		      FROM dbo.sysalerts AS sa
              INNER JOIN dbo.sysnotifications AS sn
              ON sa.id = sn.alert_id
              WHERE sa.name = @Error823AlertName)
	BEGIN
		EXEC msdb.dbo.sp_add_notification @alert_name = @Error823AlertName, @operator_name = @OperatorName, @notification_method = 1;
	END
	
-- Error 824: Logical consistency-based I/O error - Possible corruption of on disk data
-- How to troubleshoot Msg 824 in SQL Server
-- http://support.microsoft.com/kb/2015756
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @Error824AlertName)
	EXEC msdb.dbo.sp_add_alert @name = @Error824AlertName, 
				  @message_id = 824, @severity = 0, @enabled = 1, 
				  @delay_between_responses = 900, @include_event_description_in = 1, 
				  @category_name = @CategoryName, 
				  @job_id  = N'00000000-0000-0000-0000-000000000000';


-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
		      FROM dbo.sysalerts AS sa
              INNER JOIN dbo.sysnotifications AS sn
              ON sa.id = sn.alert_id
              WHERE sa.name = @Error824AlertName)
	BEGIN
		EXEC msdb.dbo.sp_add_notification @alert_name = @Error824AlertName, @operator_name = @OperatorName, @notification_method = 1;
	END


GO