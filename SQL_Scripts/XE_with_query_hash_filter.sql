/*Slide*/
IF EXISTS (SELECT * FROM [master].[sys].[server_event_sessions] WHERE NAME = 'QueryPlanLWPFilter')
BEGIN 
    DROP EVENT SESSION [QueryPlanLWPFilter] ON SERVER 
END;
CREATE EVENT SESSION [QueryPlanLWPFilter] ON SERVER
ADD EVENT sqlserver.query_post_execution_plan_profile
(
  ACTION
  (
    sqlserver.client_hostname,
    sqlserver.database_name,
    sqlserver.nt_username,
    sqlserver.query_hash,
    sqlserver.query_plan_hash,
    sqlserver.sql_text,
    sqlos.task_time,
    sqlserver.transaction_id
  )
  WHERE 
  (
    ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'AdventureWorks2017')) 
    AND 
      [sqlserver].[is_system]=(0)
    AND 
      [sqlserver].[query_hash]=(10527649358969842984.)
  )
)
ADD TARGET package0.event_file (SET filename = N'C:\Temp\XEL\QueryPlanLWPFilter.xel',max_file_size=(1024),max_rollover_files=(5))
WITH
(
  MAX_MEMORY            = 24MB,
  EVENT_RETENTION_MODE  = ALLOW_SINGLE_EVENT_LOSS,
  MAX_DISPATCH_LATENCY  = 30 SECONDS,
  MAX_EVENT_SIZE        = 0KB,
  MEMORY_PARTITION_MODE = NONE,
  TRACK_CAUSALITY       = OFF,
  STARTUP_STATE         = OFF
)
GO
