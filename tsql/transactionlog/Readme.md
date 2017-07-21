# Transaction Log Reading

## readTransactionLog.sql

Includes some common queries using fn_dblog (can read current log) and fn_dblog_dump (which reads from a log backup). These can be used to identify the LSN of certain operations if point in time recovery is desired. 

Includes queries for -> finding records related to user tables and other user objects (filter out system entries)
                     -> joins to indentify user who made a specific transaction
