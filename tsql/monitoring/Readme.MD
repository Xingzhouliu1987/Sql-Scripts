# Monitoring and Data Collector Related Scripts
Scripts with names ending in Install should be run on new servers/databases

## FixDropCollectorJobInstall.sql

This script is a patch for [dbo].[sp_syscollector_delete_jobs], which corrects bug that prevents deletion of custom collector sets per this issue (https://connect.microsoft.com/SQLServer/feedback/details/2179731/error-when-deleting-a-custom-data-collector). Otherwise, deletions of custom collector sets will fail with an error in [dbo].[sp_syscollector_delete_jobs] (Server <Servername> could not be found).
