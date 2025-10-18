BEGIN TRAN
/*CREATE TABLE [dbo].[CapturedPlans]*/
CREATE TABLE [dbo].[CapturedPlans](
  [name] [nvarchar](max) NULL,
  [timestamp] [datetimeoffset](7) NULL,
  [timestamp (UTC)] [datetimeoffset](7) NULL,
  [source_database_id] [bigint] NULL, 
  [object_type] [nvarchar](max) NULL,
  [object_id] [int] NULL,
  [nest_level] [int] NULL,
  [cpu_time] [decimal](20, 0) NULL,
  [duration] [decimal](20, 0) NULL,
  [estimated_rows] [int] NULL,
  [estimated_cost] [int] NULL,
  [serial_ideal_memory_kb] [decimal](20, 0) NULL,
  [requested_memory_kb] [decimal](20, 0) NULL,
  [used_memory_kb] [decimal](20, 0) NULL,
  [ideal_memory_kb] [decimal](20, 0) NULL,
  [granted_memory_kb] [decimal](20, 0) NULL,
  [dop] [bigint] NULL,
  [object_name] [nvarchar](max) NULL,
  [showplan_xml] [nvarchar](max) NULL,
  [database_name] [nvarchar](max) NULL,
  [transaction_id] [bigint] NULL,
  [sql_text] [nvarchar](max) NULL,
  [query_plan_hash] [decimal](20, 0) NULL,
  [query_hash] [decimal](20, 0) NULL,
  [nt_username] [nvarchar](max) NULL,
  [client_hostname] [nvarchar](max) NULL,
  [task_time] [decimal](20, 0) NULL,
  begin_offset [int] NULL,	
  end_offset [int] NULL,
  plan_handle [varbinary](max) NULL,	
  sql_handle [varbinary](max) NULL,
  recompile_count [decimal](20, 0) NULL,
  [CapturedPlans_id] [int] IDENTITY(1,1) NOT NULL,
  CONSTRAINT [PK_CapturedPlans_id] PRIMARY KEY CLUSTERED ([CapturedPlans_id] ASC)
) 
GO
/*Create table [dbo].[StmtSimple]*/
CREATE TABLE [dbo].[StmtSimple]
(
  [StmtSimple_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [StatementCompId] [int] NULL,
  [StatementEstRows] [float] NULL, 
  [StatementId] [int] NULL,
  [QueryCompilationReplay] [int] NULL,
  [StatementOptmLevel] [varchar](32) NULL,
  [StatementOptmEarlyAbortReason] [varchar] (20) NULL,
  [CardinalityEstimationModelVersion] [int] NULL,
  [StatementSubTreeCost] [float] NULL, 
  [StatementText] [nvarchar] (max) NULL,
  [StatementType] [nvarchar] (128) NULL,
  [TemplatePlanGuideDB] [nvarchar] (256) NULL,
  [TemplatePlanGuideName] [nvarchar] (256) NULL,
  [PlanGuideDB] [nvarchar] (128) NULL,
  [PlanGuideName] [nvarchar] (256) NULL,
  [ParameterizedText] [nvarchar] (max) NULL,
  [ParameterizedPlanHandle] [nvarchar] (max) NULL,
  [QueryHash] [nvarchar] (256) NULL,
  [QueryPlanHash] [nvarchar] (256) NULL,
  [RetrievedFromCache] [bit] NULL,
  [StatementSqlHandle] [nchar](10) NULL,
  [DatabaseContextSettingsId] [int] NULL,
  [ParentObjectId] [int] NULL,
  [BatchSqlHandle] [nchar](10) NULL,
  [StatementParameterizationType] [int] NULL,
  [SecurityPolicyApplied] [bit] NULL,
  [BatchModeOnRowStoreUsed] [bit] NULL,
  [QueryStoreStatementHintId] [int] NULL,
  [QueryStoreStatementHintText] [nvarchar] (256) NULL,
  [QueryStoreStatementHintSource] [nvarchar] (256) NULL,
  [ContainsLedgerTables]  [bit] NULL,
  CONSTRAINT [PK_StmtSimple] PRIMARY KEY CLUSTERED ([StmtSimple_id] ASC),
  CONSTRAINT [FK_StmtSimple_CapturedPlans_id] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
) 
/*Create table [dbo].[StatementSetOptions]*/
CREATE TABLE [dbo].[StatementSetOptions]
(
  [StatementSetOptions_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [ANSI_NULLS] [bit] NULL,
  [ANSI_PADDING] [bit] NULL,
  [ANSI_WARNINGS] [bit] NULL,
  [ARITHABORT] [bit] NULL,
  [CONCAT_NULL_YIELDS_NULL] [bit] NULL,
  [NUMERIC_ROUNDABORT] [bit] NULL,
  [QUOTED_IDENTIFIER] [bit] NULL,
  CONSTRAINT [PK__StatementSetOptions] PRIMARY KEY CLUSTERED ([StatementSetOptions_id] ASC),
  CONSTRAINT [FK_StatementSetOptions_CapturedPlans] FOREIGN KEY  (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
)
/*Create table [dbo].[QueryPlan]*/
CREATE TABLE [dbo].[QueryPlan]
(
  [QueryPlan_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [DegreeOfParallelism] [int] NULL,
  [EffectiveDegreeOfParallelism] [int] NULL,
  [NonParallelPlanReason] [nvarchar](128) NULL,
  [DOPFeedbackAdjusted] [varchar](14) NULL,
  [MemoryGrant] [bigint] NULL,
  [CachedPlanSize] [bigint] NULL,
  [CompileTime] [bigint] NULL,
  [CompileCPU] [bigint] NULL,
  [CompileMemory] [bigint] NULL,
  [UsePlan] [bit] NULL,
  [ContainsInterleavedExecutionCandidates] [bit] NULL,
  [ContainsInlineScalarTsqlUdfs] [bit] NULL,
  [QueryVariantID] [int] NULL,
  [DispatcherPlanHandle] [nchar](10) NULL,
  [ExclusiveProfileTimeActive] [bit] NULL,
  CONSTRAINT [PK__QueryPlan] PRIMARY KEY CLUSTERED ([QueryPlan_id] ASC),
  CONSTRAINT [FK_QueryPlan_CapturedPlans] FOREIGN KEY  (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
)
/*CREATE TABLE [dbo].[MissingIndex]*/
CREATE TABLE [dbo].[MissingIndex]
(
  [CapturedPlans_id] [int] NOT NULL,
  CONSTRAINT [PK_MissingIndex] PRIMARY KEY CLUSTERED ([CapturedPlans_id] ASC),
  CONSTRAINT [FK_MissingIndex_CapturedPlans] FOREIGN KEY  (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
)
/*Create table [dbo].[Warnings]*/
CREATE TABLE [dbo].[Warnings](
  [Warning_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [IsColumnsWithNoStatistics] [bit] DEFAULT 0,
  [IsColumnsWithStaleStatistics] [bit] DEFAULT 0,
  [IsExchangeSpillDetails] [bit] DEFAULT 0,
  [IsHashSpillDetails] [bit] DEFAULT 0,
  [IsMemoryGrantWarning] [bit] DEFAULT 0,
  [IsNoJoinPredicate] [bit] DEFAULT 0,
  [IsPlanAffectingConvert] [bit] DEFAULT 0,
  [IsSortSpillDetails] [bit] DEFAULT 0,
  [IsSpillOccurred] [bit] DEFAULT 0,
  [IsSpillToTempDb] [bit] DEFAULT 0,
  [IsUnmatchedIndexes] [bit] DEFAULT 0,
  [IsWait] [bit] DEFAULT 0,
  [Server] [nvarchar](128) NULL,
  [Database] [nvarchar](128) NULL,
  [Schema] [nvarchar](128) NULL,
  [Table] [nvarchar](128) NULL,
  [Alias] [nvarchar](128) NULL,
  [Index] [nvarchar](128) NULL,
  [Column] [nvarchar](128) NULL,
  [ComputedColumn] [bit] NULL,
  [ParameterDataType] [nvarchar](128) NULL,
  [ParameterCompiledValue] [nvarchar](max) NULL,
  [ParameterRuntimeValue] [nvarchar](max) NULL,
  [ConvertIssue] [varchar](20)  NULL,
  [Expression] [varchar](MAX)  NULL,
  [GrantWarningType] [varchar](23) NULL,
  [RequestedMemory] [decimal](38,0) NULL,
  [GrantedMemory] [decimal](38,0) NULL,
  [MaxUsedMemory] [decimal](38,0) NULL,
  [SpillLevel] [int] NULL,
  [SpilledThreadCount] [int] NULL,
  [GrantedMemoryKb] [int] NULL,
  [UsedMemoryKb] [int] NULL,
  [WritesToTempDb] [int] NULL,
  [ReadsFromTempDb] [int] NULL,
  [WaitType] [varchar](128) NULL,
  [WaitTime] [int] NULL,
  [Detail] [bit] NULL,
  CONSTRAINT [PK__Warnings] PRIMARY KEY CLUSTERED ([Warning_id] ASC),
  CONSTRAINT [FK_Warnings_CapturedPlans] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
)
GO
/*Create table [dbo].[MemoryGrantInfo]*/
CREATE TABLE [dbo].[MemoryGrantInfo]
(
  [MemoryGrantInfo_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [SerialRequiredMemory] [bigint] NOT NULL,
  [SerialDesiredMemory] [bigint] NOT NULL,
  [RequiredMemory] [bigint] NULL,
  [DesiredMemory] [bigint] NULL,
  [RequestedMemory] [bigint] NULL,
  [GrantWaitTime] [bigint] NULL,
  [GrantedMemory] [bigint] NULL,
  [MaxUsedMemory] [bigint] NULL,
  [MaxQueryMemory] [bigint] NULL,
  [LastRequestedMemory] [bigint] NULL,
  [IsMemoryGrantFeedbackAdjusted] [varchar] (25) NULL,
  CONSTRAINT [PK_MemoryGrantInfo] PRIMARY KEY CLUSTERED ([MemoryGrantInfo_id]ASC) ,
  CONSTRAINT [FK_MemoryGrantInfo_CapturedPlans] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id),
  CONSTRAINT [CK_IsMemoryGrantFeedbackAdjusted] CHECK (([IsMemoryGrantFeedbackAdjusted]='Yes: Percentile Adjusting' OR 
                                                        [IsMemoryGrantFeedbackAdjusted]='No: Feedback Disabled' OR 
                                                        [IsMemoryGrantFeedbackAdjusted]='No: Accurate Grant' OR 
                                                        [IsMemoryGrantFeedbackAdjusted]='No: First Execution' OR 
                                                        [IsMemoryGrantFeedbackAdjusted]='Yes: Stable' OR 
                                                        [IsMemoryGrantFeedbackAdjusted]='Yes: Adjusting'))
)
/*Create table [dbo].[MemoryGrantInfo]*/
CREATE TABLE [dbo].[OptimizerHardwareDependentProperties]
(
  [OptimizerHardwareDependentProperties_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [EstimatedAvailableMemoryGrant] [bigint] NULL,
  [EstimatedPagesCached] [bigint] NULL,
  [EstimatedAvailableDegreeOfParallelism] [bigint] NULL,
  [MaxCompileMemory] [bigint] NULL,
  CONSTRAINT [PK_OptimizerHardwareDependentProperties] PRIMARY KEY CLUSTERED ([OptimizerHardwareDependentProperties_id] ASC),
  CONSTRAINT [FK_OptimizerHardwareDependentProperties_CapturedPlans] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
)
/*Create table [dbo].[TraceFlag]*/
CREATE TABLE [dbo].[TraceFlag]
(
  [TraceFlag_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [Value] [int] NOT NULL,
  [Scope] [nvarchar] (256) NOT NULL, 
  CONSTRAINT [PK_TraceFlags] PRIMARY KEY CLUSTERED ([TraceFlag_id] ASC),
  CONSTRAINT [FK_TraceFlags_CapturedPlans] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
)
/*Create table [dbo].[WaitStats]*/
CREATE TABLE [dbo].[WaitStats](
  [WaitStats_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [WaitType] [nvarchar](128) NOT NULL,
  [WaitTimeMs] [bigint] NOT NULL,
  [WaitCount] [bigint] NULL,
  CONSTRAINT [PK_WaitStats] PRIMARY KEY CLUSTERED ([WaitStats_id] ASC),
  CONSTRAINT [FK_WaitStats_CapturedPlans] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
) 
/*Create table [dbo].[QueryTimeStats]*/
CREATE TABLE [dbo].[QueryTimeStats]
(
  [QueryTimeStats_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [CpuTime] [bigint] NULL,
  [ElapsedTime] [bigint] NULL,
  [UdfCpuTime] [bigint] NULL,
  [UdfElapsedTime] [bigint] NULL,
  CONSTRAINT [PK_QueryTimeStats] PRIMARY KEY CLUSTERED ([QueryTimeStats_id] ASC),
  CONSTRAINT [FK_QueryTimeStats_CapturedPlans] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
) 
/*Create table [dbo].[Relop]*/
CREATE TABLE [dbo].[Relop]
(
  [Relop_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,                     
  [AvgRowSize][float] NOT NULL,                                         
  [EstimateCPU][float] NOT NULL, 
  [EstimateIO] [float] NOT NULL,                                    
  [EstimateRebinds] [float] NOT NULL,                                  
  [EstimateRewinds] [float] NOT NULL,                                 
  [EstimatedExecutionMode] varchar(5) NULL,    
  [GroupExecuted] [bit] NULL,  
  [EstimateRows] [float] NOT NULL,   
  [EstimateRowsWithoutRowGoal] [float] NULL, 
  [EstimatedRowsRead] [float] NULL,  
  [LogicalOp] varchar(32) NOT NULL,                                         
  [NodeId] [int] NULL,
  [Parallel] [bit] NOT NULL,    
  [RemoteDataAccess] [bit] NULL, 
  [Partitioned] [bit] NULL,                                   
  [PhysicalOp] varchar(32) NOT NULL,  
  [IsAdaptive] [bit] NULL,
  [AdaptiveThresholdRows] [float] NULL, 
  [EstimatedTotalSubtreeCost] [float] NOT NULL, 
  [TableCardinality][float] NULL,
  [StatsCollectionId] [int] NULL,
  [EstimatedJoinType] varchar(32) NULL,                             
  [HyperScaleOptimizedQueryProcessing] varchar(32) NULL,            
  [HyperScaleOptimizedQueryProcessingUnusedReason] varchar(32) NULL,  
  [EstimateNumberOfExecutions] [float] NULL, 
  [EstimateNumberOfRowsForAllExecutions] [float] NULL,                                                  
  CONSTRAINT [PK_Relop] PRIMARY KEY CLUSTERED ([Relop_id] ASC),
  CONSTRAINT [FK_Relop_CapturedPlans] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
) 
/*Create table [dbo].[ParameterList]*/
CREATE TABLE [dbo].[ParameterList]
(
  [ParameterList_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [Column] [nvarchar](128) NOT NULL,
  [ParameterDataType] [nvarchar](128) NOT NULL,
  [ParameterCompiledValue] [nvarchar](max) NULL,
  [ParameterRuntimeValue] [nvarchar](max) NULL,
	CONSTRAINT [PK_ParameterList] PRIMARY KEY CLUSTERED ([ParameterList_id] ASC),
  CONSTRAINT [FK_ParameterList_CapturedPlans] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
) 
/*Create table [dbo].[StatisticsInfo]*/
CREATE TABLE [dbo].[StatisticsInfo]
(
  [StatisticsInfo_id] [int] IDENTITY(1,1) NOT NULL,
  [CapturedPlans_id] [int] NOT NULL,
  [Database] [nvarchar](256) NULL,
  [Schema] [nvarchar](256) NULL,
  [Table] [nvarchar](256) NULL,
  [Statistics] [nvarchar](256) NULL,
  [ModificationCount] [bigint] NULL,
  [SamplingPercent] [float] NULL,
  [LastUpdate] [DateTime] NULL,
  CONSTRAINT [PK_StatisticsInfo] PRIMARY KEY CLUSTERED ([StatisticsInfo_id] ASC),
  CONSTRAINT [FK_StatisticsInfo_CapturedPlans] FOREIGN KEY (CapturedPlans_id) REFERENCES [dbo].[CapturedPlans](CapturedPlans_id)
) 
/*Create table [dbo].[RunTimeCountersPerThread]*/
CREATE TABLE [dbo].[RunTimeCountersPerThread]
(
  [RunTimeCountersPerThread_id] [int] IDENTITY(1,1) NOT NULL,
  [Relop_id] [int] NOT NULL,
  [ActualCPUms] [decimal](38,0) NULL,
  [ActualElapsedms] [decimal](38,0) NULL,
  [ActualEndOfScans] [int] NULL,
  [ActualExecutionMode] [varchar](5) NULL,
  [ActualExecutions] [decimal](38,0) NULL,
  [ActualJoinType] [varchar](32) NULL,   
  [ActualLobLogicalReads] [int] NULL,
  [ActualLobPageServerReadAheads] [int] NULL,
  [ActualLobPageServerReads] [int] NULL,
  [ActualLobPhysicalReads] [int] NULL,
  [ActualLobReadAheads] [int] NULL,
  [ActualLocallyAggregatedRows] [int] NULL,
  [ActualLogicalReads] [decimal](38,0) NULL,
  [ActualPageServerPushedPageIDs] [int] NULL,
  [ActualPageServerPushedReads] [int] NULL,    
  [ActualPageServerReadAheads] [int] NULL,
  [ActualPageServerReads] [int] NULL,
  [ActualPageServerRowsRead] [int] NULL,
  [ActualPageServerRowsReturned] [int] NULL,
  [ActualPhysicalReads] [decimal](38,0) NULL,
  [ActualReadAheads] [int] NULL,
  [ActualRebinds] [int] NULL,
  [ActualRewinds] [int] NULL,
  [ActualRows] [decimal](38,0) NULL,
  [ActualRowsRead] [decimal](38,0) NULL,
  [ActualScans] [decimal](38,0) NULL,
  [Batches] [int] NULL,
  [BrickId] [int] NULL,
  [CloseTime] [int] NULL,
  [FirstActiveTime] [int] NULL,
  [FirstRowTime] [int] NULL,
  [HpcDeviceToHostBytes] [int] NULL,
  [HpcHostToDeviceBytes] [int] NULL,
  [HpcKernelElapsedUs] [int] NULL,
  [HpcRowCount] [int] NULL,
  [InputMemoryGrant] [int] NULL,
  [IsInterleavedExecuted] [bit] NULL,
  [LastActiveTime] [int] NULL,
  [LastRowTime] [int] NULL,
  [NodeId] [int] NOT NULL,
  [OpenTime] [int] NULL,
  [OutputMemoryGrant] [int] NULL,
  [RowRequalifications] [int] NULL,
  [SchedulerId] [int] NULL,
  [SegmentReads] [int] NULL,
  [SegmentSkips] [int] NULL,
  [TaskAddr] [int] NULL,
  [Thread] [int] NULL,
  [UsedMemoryGrant] [int] NULL,
  CONSTRAINT [PK_RunTimeCountersPerThread] PRIMARY KEY CLUSTERED ([RunTimeCountersPerThread_id] ASC),
  CONSTRAINT [FK_RunTimeCountersPerThread_Relop] FOREIGN KEY (Relop_id) REFERENCES [dbo].[Relop](Relop_id),
  CONSTRAINT [CK_RunTimeCountersPerThread_ActualExecutionMode] CHECK  (([ActualExecutionMode]='Row' OR [ActualExecutionMode]='Batch'))
) 
GO
/*Create view [dbo].[vw_Actuals]*/
CREATE VIEW [dbo].[vw_Actuals]
AS 
  SELECT 
    [dbo].[Relop].[CapturedPlans_id],
    [dbo].[RunTimeCountersPerThread].[NodeId],
    [dbo].[Relop].[PhysicalOp],
    SUM([dbo].[RunTimeCountersPerThread].[ActualRows]) AS [Sum_ActualRows],
    COALESCE ([dbo].[Relop].[EstimateNumberOfRowsForAllExecutions],[dbo].[Relop].[EstimateRows]) AS [Sum_EstimateRows],
    [dbo].[Relop].[EstimateRows],
    [dbo].[Relop].[EstimateNumberOfExecutions],
    [dbo].[Relop].[EstimateNumberOfRowsForAllExecutions],
    CASE 
      WHEN SUM([dbo].[RunTimeCountersPerThread].[ActualRows]) = 0 THEN 0
        ELSE 100/(SUM([dbo].[RunTimeCountersPerThread].[ActualRows])) *  (COALESCE ([dbo].[Relop].[EstimateNumberOfRowsForAllExecutions],[dbo].[Relop].[EstimateRows],0)) 
      END AS [perc1],
    [dbo].[StmtSimple].[QueryHash],
    [dbo].[StmtSimple].[QueryPlanHash]
  FROM 
    [dbo].[RunTimeCountersPerThread] INNER JOIN
    [dbo].[Relop] ON [dbo].[RunTimeCountersPerThread].Relop_id = [dbo].[Relop].Relop_id AND [dbo].[RunTimeCountersPerThread].NodeId = [dbo].[Relop].NodeId INNER JOIN
		[dbo].[StmtSimple] ON [dbo].[StmtSimple].CapturedPlans_id = [dbo].[Relop].[CapturedPlans_id]
  GROUP BY 
    [dbo].[Relop].[CapturedPlans_id],
    [dbo].[RunTimeCountersPerThread].[Relop_id],
    [dbo].[RunTimeCountersPerThread].[NodeId],
    [dbo].[Relop].[PhysicalOp],
    [dbo].[Relop].[EstimateRows],
    [dbo].[StmtSimple].[QueryHash],
    [dbo].[StmtSimple].[QueryPlanHash],
    [dbo].[Relop].[EstimateNumberOfRowsForAllExecutions],
    [dbo].[Relop].[EstimateNumberOfExecutions]
GO
/*Create view [dbo].[vw_ParameterList]*/
CREATE VIEW [dbo].[vw_ParameterList]
AS
  SELECT  
    p.[CapturedPlans_id]
		,cp.[database_name]
    ,STRING_AGG(p.[Column] + ' ' + p.ParameterDataType  + ' ' + p.ParameterCompiledValue + ' ' + p.ParameterRuntimeValue,', ')WITHIN GROUP (order by [Column]) AS [name_type_compiled_runtime]
    ,qts.[CpuTime]
    ,qts.[ElapsedTime]
    ,qts.[UdfCpuTime]
		,qts.[UdfElapsedTime]
    ,ss.[QueryHash]
    ,ss.[QueryPlanHash]
    ,TRY_CONVERT (XML,cp.showplan_xml) AS [showplan_xml]
		,cp.[sql_text]
  FROM 
    dbo.[ParameterList] p INNER JOIN 
    [dbo].[QueryTimeStats] qts ON qts.CapturedPlans_id = p.CapturedPlans_id INNER JOIN 
    [dbo].[StmtSimple] ss ON ss.CapturedPlans_id = p.CapturedPlans_id INNER JOIN 
    [dbo].[CapturedPlans] cp ON p.CapturedPlans_id = cp.CapturedPlans_id 
  WHERE 
    p.ParameterCompiledValue IS NOT NULL
  GROUP BY 
     p.[CapturedPlans_id]
		,cp.[database_name]
    ,qts.[CpuTime]
    ,qts.[ElapsedTime]
    ,qts.[UdfCpuTime]
		,qts.[UdfElapsedTime]
    ,ss.[QueryHash]
    ,ss.[QueryPlanHash]
    ,cp.[showplan_xml]
		,cp.[sql_text];
GO
/*Create view [dbo].[vw_ParameterListCompiled]*/
CREATE VIEW [dbo].[vw_ParameterListCompiled]
AS
  SELECT  
    p.CapturedPlans_id 
    ,cp.timestamp
    ,STRING_AGG(p.[Column] + ' ' + p.ParameterDataType  + ' ' + p.ParameterCompiledValue ,', ')WITHIN GROUP (order by [Column]) AS [parameter_info]
    ,qts.CpuTime
    ,qts.ElapsedTime
    ,ss.QueryHash
    ,ss.QueryPlanHash
    ,TRY_CONVERT (XML,cp.showplan_xml) AS [showplan_xml]
  FROM 
    dbo.[ParameterList] p INNER JOIN 
    [dbo].[QueryTimeStats] qts ON qts.CapturedPlans_id = p.CapturedPlans_id INNER JOIN 
    [dbo].[StmtSimple] ss ON ss.CapturedPlans_id = p.CapturedPlans_id INNER JOIN 
    [dbo].[CapturedPlans] cp ON p.CapturedPlans_id = cp.CapturedPlans_id 
  WHERE 
    p.ParameterCompiledValue IS NOT NULL
  GROUP BY 
    p.CapturedPlans_id
    ,qts.CpuTime
    ,qts.ElapsedTime
    ,ss.QueryHash
    ,ss.QueryPlanHash
    ,cp.[showplan_xml]
    ,cp.timestamp
GO
/*Create view [dbo].[vw_ParameterListRuntime]*/
CREATE VIEW [dbo].[vw_ParameterListRuntime]
AS
  SELECT  
    p.CapturedPlans_id 
    ,cp.timestamp
    ,STRING_AGG(p.[Column] + ' ' + p.ParameterDataType  + ' ' + p.ParameterRuntimeValue,', ')WITHIN GROUP (order by [Column]) AS [parameter_info]
    ,qts.CpuTime
    ,qts.ElapsedTime
    ,ss.QueryHash
    ,ss.QueryPlanHash
    ,TRY_CONVERT (XML,cp.showplan_xml) AS [showplan_xml]
  FROM 
    dbo.[ParameterList] p INNER JOIN 
    [dbo].[QueryTimeStats] qts ON qts.CapturedPlans_id = p.CapturedPlans_id INNER JOIN 
    [dbo].[StmtSimple] ss ON ss.CapturedPlans_id = p.CapturedPlans_id INNER JOIN 
    [dbo].[CapturedPlans] cp ON p.CapturedPlans_id = cp.CapturedPlans_id 
  WHERE 
    p.ParameterCompiledValue IS NOT NULL
  GROUP BY 
    p.CapturedPlans_id
    ,qts.CpuTime
    ,qts.ElapsedTime
    ,ss.QueryHash
    ,ss.QueryPlanHash
    ,cp.[showplan_xml]
    ,cp.timestamp
GO
/*Create view [dbo].[vw_Multiple_Plans_Per_QueryHash]*/
CREATE VIEW [dbo].[vw_Multiple_Plans_Per_QueryHash]
AS
  SELECT
     cp.[query_hash] AS [XE_query_hash]
    ,ss.QueryHash
    ,COUNT(DISTINCT QueryPlanHash) AS PlanCount
  FROM 
    [dbo].[CapturedPlans] cp
      INNER JOIN 
    [dbo].[StmtSimple] ss ON cp.CapturedPlans_id = ss.CapturedPlans_id
  GROUP BY 
     QueryHash
    ,cp.[query_hash] 
  HAVING  
    COUNT(DISTINCT QueryPlanHash) > 1;
GO
/*[dbo].[vw_PlanWarning_Wait]*/
CREATE VIEW [dbo].[vw_PlanWarning_Wait]
AS
  SELECT 
     w.[Warning_id]
    ,w.[CapturedPlans_id]
    ,w.[WaitType]
    ,w.[WaitTime]
    ,TRY_CONVERT(xml,cp.showplan_xml) [showplan_xml]
    ,cp.sql_text
  FROM 
		[dbo].[Warnings] w
			INNER JOIN 
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
  WHERE
		[IsWait] = 1
GO
/*CREATE VIEW [dbo].[vw_QueryWithUdf]*/
CREATE VIEW [dbo].[vw_QueryWithUdf]
AS 
SELECT 
	 CP.[CapturedPlans_id]
	,TRY_CONVERT(XML,CP.showplan_xml) AS [showplan_xml]
	,[UdfCpuTime]
	,[UdfElapsedTime]
FROM 
	[dbo].[QueryTimeStats] QTS
		INNER JOIN 
	[dbo].[CapturedPlans] CP ON QTS.CapturedPlans_id = CP.CapturedPlans_id
WHERE 
	QTS.[UdfCpuTime] IS NOT NULL
GO
/*Create view [dbo].[vw_PlanWarning_MemoryGrantWarning]*/
CREATE VIEW [dbo].[vw_PlanWarning_MemoryGrantWarning]
AS
	SELECT 
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,[IsMemoryGrantWarning]
		,[GrantWarningType]
		,[RequestedMemory]
		,[GrantedMemory]
		,[MaxUsedMemory]
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM  
		[dbo].[Warnings]  w
			INNER JOIN 
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE 
		IsMemoryGrantWarning = 1
GO
/*Create view [dbo].[vw_PlanWarning_SpillToTempDb]*/
CREATE VIEW [dbo].[vw_PlanWarning_SpillToTempDb]
AS
	SELECT
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,w.[SpillLevel] 
		,w.[SpilledThreadCount]
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[Warnings] w
			INNER JOIN 
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE 
		[IsSpillToTempDb] = 1
GO
/*Create view [dbo].[vw_PlanWarning_HashSpillDetails]*/
CREATE VIEW [dbo].[vw_PlanWarning_HashSpillDetails]
AS
	SELECT
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,w.[GrantedMemoryKb] 
		,w.[UsedMemoryKb]
		,w.[WritesToTempDb] 
		,w.[ReadsFromTempDb]
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[Warnings] w
			INNER JOIN 
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE 
		[IsHashSpillDetails] = 1
GO
/*Create view [dbo].[vw_PlanWarning_SortSpillDetails]*/
CREATE VIEW [dbo].[vw_PlanWarning_SortSpillDetails]
AS
	SELECT 
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,w.[GrantedMemoryKb] 
		,w.[UsedMemoryKb]
		,w.[WritesToTempDb] 
		,w.[ReadsFromTempDb]
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[Warnings] w
			INNER JOIN
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE
		[IsSortSpillDetails] = 1
GO
/*Create view [dbo].[vw_PlanWarning_ExchangeSpillDetails]*/
CREATE VIEW [dbo].[vw_PlanWarning_ExchangeSpillDetails]
AS
	SELECT		
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,w.[WritesToTempDb] 
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[Warnings] w
			INNER JOIN 
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE
		[IsExchangeSpillDetails] = 1
GO
/*Create view [dbo].[vw_PlanWarning_ColumnsWithNoStatistics]*/
CREATE VIEW [dbo].[vw_PlanWarning_ColumnsWithNoStatistics]
AS
	SELECT 		
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,w.[Server]
		,w.[Database]
		,w.[Schema]
		,w.[Table]
		,w.[Alias]
		,w.[Column]
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[Warnings] w
			INNER JOIN 
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE 
		[IsColumnsWithNoStatistics] = 1
GO
/*Create view [dbo].[vw_PlanWarning_ColumnsWithStaleStatistics]*/
CREATE VIEW [dbo].[vw_PlanWarning_ColumnsWithStaleStatistics]
AS
	SELECT 
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,w.[Server]
		,w.[Database]
		,w.[Schema]
		,w.[Table]
		,w.[Alias]
		,w.[Column]
		,w.[ComputedColumn]
		,w.[ParameterDataType]
		,w.[ParameterCompiledValue]
		,w.[ParameterRuntimeValue]
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[Warnings] w
			INNER JOIN
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE 
		[IsColumnsWithStaleStatistics] = 1
GO
/*Create view [dbo].[vw_PlanWarning_NoJoinPredicate]*/
CREATE VIEW [dbo].[vw_PlanWarning_NoJoinPredicate]
AS
	SELECT		
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[Warnings] w
			INNER JOIN 
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE
		[IsNoJoinPredicate] = 1
GO
/*Create view [dbo].[vw_PlanWarning_UnmatchedIndexes]*/
CREATE VIEW [dbo].[vw_PlanWarning_UnmatchedIndexes]
AS
	SELECT		
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,w.[Server]
		,w.[Database]
		,w.[Schema]
		,w.[Table]
		,w.[Index]
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[Warnings] w
			INNER JOIN 
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE
		[IsUnmatchedIndexes] = 1
GO
/*Create view [dbo].[vw_PlanWarning_PlanAffectingConvert]*/
CREATE VIEW [dbo].[vw_PlanWarning_PlanAffectingConvert]
AS
	SELECT 		
		 w.[Warning_id]
		,w.[CapturedPlans_id]
		,w.[ConvertIssue]
		,w.[Expression]
		,TRY_CONVERT(xml,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[Warnings] w
			INNER JOIN 
		[dbo].[CapturedPlans] cp ON w.CapturedPlans_id = cp.CapturedPlans_id
	WHERE 
		[IsPlanAffectingConvert] = 1
GO
/*Create view [dbo].[vw_PlanWarning_Overview]*/
CREATE VIEW [dbo].[vw_PlanWarning_Overview]
		AS
		SELECT
			 SUM(TRY_CONVERT(int,[IsSpillOccurred]))              AS [IsSpillOccurred]
			,SUM(TRY_CONVERT(int,[IsColumnsWithNoStatistics]))    AS [IsColumnsWithNoStatistics]
			,SUM(TRY_CONVERT(int,[IsColumnsWithStaleStatistics])) AS [IsColumnsWithStaleStatistics]
			,SUM(TRY_CONVERT(int,[IsSpillToTempDb]))              AS [IsSpillToTempDb]
			,SUM(TRY_CONVERT(int,[IsWait]))                       AS [IsWait]
			,SUM(TRY_CONVERT(int,[IsPlanAffectingConvert]))       AS [IsPlanAffectingConvert]
			,SUM(TRY_CONVERT(int,[IsSortSpillDetails]))           AS [IsSortSpillDetails]
			,SUM(TRY_CONVERT(int,[IsHashSpillDetails]))           AS [IsHashSpillDetails]
			,SUM(TRY_CONVERT(int,[IsExchangeSpillDetails]))       AS [IsExchangeSpillDetails]
			,SUM(TRY_CONVERT(int,[IsMemoryGrantWarning]))         AS [IsMemoryGrantWarning]
      ,SUM(TRY_CONVERT(int,[IsNoJoinPredicate]))            AS [IsNoJoinPredicate]
      ,SUM(TRY_CONVERT(int,[IsUnmatchedIndexes]))           AS [IsUnmatchedIndexes]
      
		FROM 
			[dbo].[Warnings]
GO
/*Create view [dbo].[vw_Duration]*/
CREATE VIEW vw_Duration
AS
	SELECT 
		 qts.[CapturedPlans_id]
		,qts.[CpuTime]
		,qts.[ElapsedTime]
		,qts.[UdfCpuTime]
		,qts.[UdfElapsedTime]
		,ss.[QueryHash]
    ,cp.[database_name]
    ,TRY_CONVERT(XML,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[QueryTimeStats] qts INNER JOIN
		[dbo].[StmtSimple] ss ON ss.CapturedPlans_id = qts.CapturedPlans_id INNER JOIN
		[dbo].[CapturedPlans] cp ON cp.CapturedPlans_id = ss.CapturedPlans_id
GO
/*Create view [dbo].[vw_Duration_Parameterized]
CREATE VIEW [dbo].[vw_Duration_Parameterized]
AS
	SELECT 
		 qts.[CapturedPlans_id]
		,qts.[CpuTime]
		,qts.[ElapsedTime]
		,qts.[UdfCpuTime]
		,qts.[UdfElapsedTime]
		,STRING_AGG(p.[Column] + ' ' + p.ParameterCompiledValue + ' ' + p.ParameterRuntimeValue,', ')WITHIN GROUP (order by [column]) AS [param_name_compile_run]
		,ss.[QueryHash]
    ,cp.[database_name]
    ,TRY_CONVERT(XML,cp.showplan_xml) AS [showplan_xml]
		,cp.sql_text
	FROM 
		[dbo].[QueryTimeStats] qts 
			INNER JOIN 
		[dbo].[StmtSimple] ss ON ss.CapturedPlans_id = qts.CapturedPlans_id 
			INNER JOIN
		[dbo].[CapturedPlans] cp ON cp.CapturedPlans_id = ss.CapturedPlans_id
			INNER JOIN 
		[dbo].[ParameterList] p ON qts.CapturedPlans_id = p.CapturedPlans_id 
	GROUP BY
		 qts.[CapturedPlans_id]
		,qts.[CpuTime]
		,qts.[ElapsedTime]
		,qts.[UdfCpuTime]
		,qts.[UdfElapsedTime]	
		,ss.[QueryHash]
		,cp.[database_name]
		,cp.showplan_xml
		,cp.sql_text
GO*/
/*CREATE VIEW [dbo].[vw_Hashes]*/
CREATE VIEW [dbo].[vw_Hashes]
AS 
	SELECT
		 cp.[CapturedPlans_id]
		,cp.[query_hash] AS [XE_query_hash]
		,ss.QueryHash
		,cp.[query_plan_hash] AS [XE_query_plan_hash]
		,ss.QueryPlanHash
	FROM 
		[dbo].[CapturedPlans] cp
			INNER JOIN 
		[dbo].[StmtSimple] ss ON cp.CapturedPlans_id = ss.CapturedPlans_id
GO
/*CREATE VIEW vw_Memory_PercentUsed*/
CREATE VIEW vw_Memory_PercentUsed
AS 
SELECT 
	 CP.[CapturedPlans_id]
	,TRY_CONVERT(XML,CP.showplan_xml) AS [showplan_xml]
	,MG.[GrantedMemory]
	,MG.[MaxUsedMemory]
	,CAST((100.0 /MG.[GrantedMemory] * MG.[MaxUsedMemory]) AS DECIMAL(18,2)) as PercentageUsed
FROM 
	[dbo].[MemoryGrantInfo] MG
		INNER JOIN 
	[dbo].[CapturedPlans] CP ON MG.CapturedPlans_id = CP.CapturedPlans_id
WHERE 
	MG.[GrantedMemory] > 0;
GO
/*CREATE VIEW vw_MemoryGrantFeedbackAdjusted*/
CREATE VIEW vw_MemoryGrantFeedbackAdjusted
AS 
SELECT 
	 CP.[CapturedPlans_id]
	,TRY_CONVERT(XML,CP.showplan_xml) AS [showplan_xml]
	,[IsMemoryGrantFeedbackAdjusted]
FROM 
	[dbo].[MemoryGrantInfo] MG
		INNER JOIN 
	[dbo].[CapturedPlans] CP ON MG.CapturedPlans_id = CP.CapturedPlans_id
WHERE 
	MG.[IsMemoryGrantFeedbackAdjusted] IS NOT NULL
	AND 
	MG.[IsMemoryGrantFeedbackAdjusted] IN ('Yes: Adjusting','Yes: Stable','Yes: Percentile Adjusting');
GO
/*Create view [dbo].[vw_Compile_TimeOut]*/
CREATE VIEW [dbo].[vw_Compile_TimeOut]
AS
SELECT
  s.[CapturedPlans_id]
  ,s.[StatementEstRows]
  ,s.[StatementOptmLevel]
  ,s.[StatementOptmEarlyAbortReason]
  ,s.[CardinalityEstimationModelVersion]
  ,s.[StatementSubTreeCost]
  ,qpi.[CachedPlanSize]
  ,qpi.[CompileTime]
  ,qpi.[CompileCPU]
  ,qpi.[CompileMemory]
  ,TRY_CONVERT(xml,cp.showplan_xml) [showplan_xml]
  ,cp.sql_text
FROM
  [dbo].[StmtSimple] s INNER JOIN
  [dbo].[QueryPlan] qpi ON s.CapturedPlans_id = qpi.CapturedPlans_id INNER JOIN
  [dbo].[CapturedPlans] cp ON s.CapturedPlans_id = cp.CapturedPlans_id
WHERE
StatementOptmEarlyAbortReason IN ('MemoryLimitExceeded','TimeOut')
GO
/*Create view [dbo].[vw_Converted_Plans]*/
CREATE VIEW [dbo].[vw_Converted_Plans]
AS 
SELECT 
	 [CapturedPlans_id]
	,[name]
	,TRY_CONVERT(xml,[showplan_xml]) AS [showplan_xml] 
	,[cpu_time]
	,[duration]
	,[estimated_rows]
	,[estimated_cost]
	,[serial_ideal_memory_kb]
	,[requested_memory_kb]
	,[used_memory_kb]
	,[ideal_memory_kb]
	,[granted_memory_kb]
	,[dop]
	,[object_name]
	,[database_name]
	,[sql_text]
  ,[query_hash]
  ,[query_plan_hash]
FROM 
	[dbo].[CapturedPlans]
GO
/*Create view [dbo].[vw_TraceFlags]*/
CREATE VIEW [dbo].[vw_TraceFlags]
AS
SELECT     
	[dbo].[CapturedPlans].[database_name], 
	[dbo].[TraceFlag].[Value], 
	[dbo].[TraceFlag].[Scope], 
	TRY_CONVERT(xml,[dbo].[CapturedPlans].[showplan_xml]) AS [showplan_xml], 
	[dbo].[CapturedPlans].[sql_text]
FROM        
	[dbo].[CapturedPlans] 
	INNER JOIN                
	[dbo].[TraceFlag] ON [dbo].[CapturedPlans].[CapturedPlans_id] = [dbo].[TraceFlag].[CapturedPlans_id]
GO
/*Create view [dbo].[vw_Parallel_Skew]*/
CREATE VIEW [dbo].[vw_Parallel_Skew] 
AS 
SELECT 
    R.[CapturedPlans_id],
    RTC.[NodeId],
		RTC.[Thread],
    RTC.[ActualRows],
		/*Calculate how much rows were handled per thread compared to the total of the operator*/
    CAST(
    ROUND(
        RTC.[ActualRows] / 
        (
            SELECT 
                CASE 
                    WHEN SUM([ActualRows]) = 0 THEN 1 /* Avoid divide by zero by using 1 as the denominator*/
                    ELSE SUM([ActualRows])
                END
            FROM 
                [dbo].[RunTimeCountersPerThread] RTC2
            WHERE 
                RTC2.[Relop_id] = RTC.Relop_id
            GROUP BY  
                RTC2.[Relop_id],
                RTC2.[NodeId]
        ) * 100, 2
    ) AS DECIMAL(18,2)
) AS [Percentage]
FROM 
    [dbo].[RunTimeCountersPerThread] RTC
    INNER JOIN 
    [dbo].[Relop] R ON RTC.Relop_id = R.Relop_id AND RTC.NodeId = R.NodeId
WHERE 
    RTC.ActualRows IS NOT NULL AND /*only operators who returned rows*/
    RTC.Thread > 0 AND /*Thread 0 is always 0*/
		R.Parallel = 1 /*Only parrellel operators*/
GROUP BY 
    R.[CapturedPlans_id],
    RTC.[NodeId],
    RTC.[ActualRows],
    RTC.[Thread],
    RTC.Relop_id;
GO
/*Create view [dbo].[vw_Missing_Index]*/
CREATE VIEW vw_Missing_Index
AS
	SELECT  
		 CP.[CapturedPlans_id]
		,TRY_CONVERT(XML,CP.showplan_xml) AS [showplan_xml]
	FROM
		[dbo].[MissingIndex] MI
			INNER JOIN 
		[dbo].[CapturedPlans] CP ON MI.CapturedPlans_id = CP.CapturedPlans_id;
GO
/*Create view [dbo].[vw_NonParallelPlanReason]*/
CREATE VIEW [dbo].[vw_NonParallelPlanReason]
AS
SELECT 
   CP.[CapturedPlans_id]
	,QP.[NonParallelPlanReason] 
	,TRY_CONVERT(XML,CP.showplan_xml) AS [showplan_xml]
FROM 
	[dbo].[QueryPlan] QP
		INNER JOIN 
	[dbo].[CapturedPlans] CP ON QP.CapturedPlans_id = CP.CapturedPlans_id
WHERE
	QP.[NonParallelPlanReason] IS NOT NULL;
GO
/*Create view [dbo].[vw_Statistics_Not_Updated_Last_7_Days]*/
CREATE VIEW [dbo].[vw_Statistics_Not_Updated_Last_7_Days]
AS
SELECT Distinct
	 [Database]
	,[Schema]
	,[Table]
	,[Statistics]
	,[ModificationCount]
	,[SamplingPercent]
	,[LastUpdate]
FROM
	[dbo].[StatisticsInfo] 
WHERE
	[Schema] <> '[sys]' AND
	[Database] NOT IN ('[msdb]','[master]') AND 
	[ModificationCount] > 0 AND 
	LastUpdate < (DATEADD(day, -7,(SELECT GETDATE())));
GO
COMMIT
/*
	[dbo].[CapturedPlans]
	top
	cpu_time
	duration
	[requested_memory_kb]
	[used_memory_kb]
	[granted_memory_kb]
*/

/*
Check [dbo].[StmtSimple]
StatementParameterizationType
ParameterizedText
[StatementParameterizationType]
*/
