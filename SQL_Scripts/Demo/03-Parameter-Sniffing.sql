/*========================================================
Create the index
========================================================*/
USE StackOverflow; 
/* helpful index for the filter + order by */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.Posts')
  AND name = 'IX_Posts_CreationDate_Score')
BEGIN
  CREATE NONCLUSTERED INDEX IX_Posts_CreationDate_Score
  ON dbo.Posts(CreationDate DESC, Score DESC)
  INCLUDE (Id, OwnerUserId);
END
GO
/*========================================================
Create the XE session
========================================================*/
/*Slide*/
IF EXISTS (SELECT * FROM [master].[sys].[server_event_sessions] WHERE name = 'QueryPlanLWP')
BEGIN 
    DROP EVENT SESSION [QueryPlanLWP] ON SERVER 
END;
CREATE EVENT SESSION [QueryPlanLWP] ON SERVER
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
    ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'StackOverflow'))
      AND 
    [sqlserver].[is_system]=(0)
  )
)
ADD TARGET package0.event_file (SET filename = N'C:\XEL\QueryPlanLWP.xel',max_file_size=(1024),max_rollover_files=(5))
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

/*========================================================
Create the SP
========================================================*/
IF OBJECT_ID('dbo.TopPostsSince', 'P') IS NOT NULL
  DROP PROCEDURE dbo.TopPostsSince;
GO

CREATE PROCEDURE dbo.TopPostsSince
  @FromDate datetime2
AS
BEGIN
  SET NOCOUNT ON;
  /* TOP keeps returned rows constant; ORDER BY forces a memory-consuming Sort */
  SELECT TOP (1000)
         p.Id, p.OwnerUserId, p.Score, p.CreationDate
  FROM   dbo.Posts AS p
  WHERE  p.CreationDate >= @FromDate
  ORDER BY p.Score DESC;
END
GO
/*========================================================
Stop XE if running
========================================================*/
IF EXISTS (SELECT 1 FROM sys.dm_xe_sessions WHERE name = 'QueryPlanLWP')
BEGIN
    ALTER EVENT SESSION [QueryPlanLWP] ON SERVER STATE = STOP;
END
/*========================================================
Clear the cache
========================================================*/
DBCC FREEPROCCACHE
/*========================================================
Start XE
========================================================*/
IF EXISTS (SELECT 1 FROM sys.dm_xe_sessions WHERE name = 'QueryPlanLWP')
BEGIN
    ALTER EVENT SESSION [QueryPlanLWP] ON SERVER STATE = STOP;
END
ALTER EVENT SESSION [QueryPlanLWP] ON SERVER STATE = START; 
/*========================================================
Run the SP
========================================================*/
GO
DECLARE @fewRowsDate  datetime2 = DATEADD(DAY, -1,  SYSUTCDATETIME()); /*last day*/
EXEC dbo.TopPostsSince @FromDate = @fewRowsDate;  
GO
DECLARE @fewRowsDate  datetime2 = DATEADD(DAY, -2,  SYSUTCDATETIME()); /*last day*/
EXEC dbo.TopPostsSince @FromDate = @fewRowsDate;  
GO
DECLARE @fewRowsDate  datetime2 = DATEADD(DAY, -3,  SYSUTCDATETIME()); /*last day*/
EXEC dbo.TopPostsSince @FromDate = @fewRowsDate;  
GO
DECLARE @fewRowsDate  datetime2 = DATEADD(DAY, -4,  SYSUTCDATETIME()); /*last day*/
EXEC dbo.TopPostsSince @FromDate = @fewRowsDate;  
GO
DECLARE @fewRowsDate  datetime2 = DATEADD(DAY, -5,  SYSUTCDATETIME()); /*last day*/
EXEC dbo.TopPostsSince @FromDate = @fewRowsDate;  
GO
DECLARE @fewRowsDate  datetime2 = DATEADD(DAY, -6,  SYSUTCDATETIME()); /*last day*/
EXEC dbo.TopPostsSince @FromDate = @fewRowsDate;  
GO
DECLARE @fewRowsDate  datetime2 = DATEADD(DAY, -7,  SYSUTCDATETIME()); /*last day*/
EXEC dbo.TopPostsSince @FromDate = @fewRowsDate;  
GO
DECLARE @fewRowsDate  datetime2 = DATEADD(DAY, -8,  SYSUTCDATETIME()); /*last day*/
EXEC dbo.TopPostsSince @FromDate = @fewRowsDate;  
GO
DECLARE @fewRowsDate  datetime2 = DATEADD(DAY, -9,  SYSUTCDATETIME()); /*last day*/
EXEC dbo.TopPostsSince @FromDate = @fewRowsDate;  

GO
DECLARE @manyRowsDate datetime2 = DATEADD(YEAR, -25, SYSUTCDATETIME()); /*last 25 years*/
EXEC dbo.TopPostsSince @FromDate = @manyRowsDate;
GO
/*========================================================
Stop XE
========================================================*/
ALTER EVENT SESSION [QueryPlanLWP] ON SERVER STATE = STOP; 
GO

/*========================================================
Results
========================================================*/
SELECT [name_type_compiled_runtime]
      ,[CpuTime]
      ,[ElapsedTime]
      ,[QueryHash]
      ,[QueryPlanHash]
      ,[showplan_xml]
      ,[sql_text]
FROM [PlanUsageInfo].[dbo].[vw_ParameterList]

SELECT [name_type_compiled_runtime]
    ,[CpuTime]
    ,[ElapsedTime]
    ,[QueryHash]
    ,[QueryPlanHash]
    ,[showplan_xml]
    ,[sql_text]
FROM [PlanUsageInfo].[dbo].[vw_ParameterList]