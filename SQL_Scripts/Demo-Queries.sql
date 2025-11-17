/*Tables*/
USE PlanUsageInfo;
/*[dbo].[CapturedPlans]*/
SELECT TOP (1000)
	 [name]
	,[timestamp]
	,[object_type]
	,[nest_level]
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
	,[showplan_xml]
	,[database_name]
	,[sql_text]
	,[query_plan_hash]
	,[query_hash]
	,[nt_username]
	,[client_hostname]
	,[CapturedPlans_id]
FROM 
	[dbo].[CapturedPlans]
/*[dbo].[StmtSimple] Compilation info*/
SELECT TOP (1000) 
	 [StmtSimple_id]
	,[CapturedPlans_id]
	,[StatementEstRows]
	,[StatementOptmLevel]
	,[StatementOptmEarlyAbortReason]
	,[CardinalityEstimationModelVersion]
	,[StatementSubTreeCost]
	,[StatementType]
	,[QueryHash]
	,[QueryPlanHash]
	,[BatchModeOnRowStoreUsed]
FROM 
	[dbo].[StmtSimple]
WHERE [BatchModeOnRowStoreUsed] <> 0
/*[dbo].[QueryPlan]*/
SELECT TOP (1000)
	 [QueryPlan_id]
	,[CapturedPlans_id]
	,[DegreeOfParallelism]
	,[NonParallelPlanReason]
	,[MemoryGrant]
	,[CachedPlanSize]
	,[CompileTime]
	,[CompileCPU]
	,[CompileMemory]
FROM 
	[dbo].[QueryPlan]
WHERE
	[NonParallelPlanReason] IS NOT NULL

SELECT TOP (1000) * FROM [dbo].[MissingIndex]
SELECT TOP (1000) * FROM [dbo].[Warnings]
SELECT TOP (1000) * FROM [dbo].[MemoryGrantInfo] WHERE [GrantWaitTime] > 0
SELECT TOP (1000) * FROM [dbo].[OptimizerHardwareDependentProperties]
SELECT TOP (1000) * FROM [dbo].[StatisticsInfo]
SELECT TOP (1000) * FROM [dbo].[TraceFlag] 
SELECT TOP (1000) * FROM [dbo].[WaitStats]
SELECT TOP (1000) * FROM [dbo].[QueryTimeStats] WHERE UdfCpuTime is not null or UdfElapsedTime is not null
/*[dbo].[Relop]*/
SELECT TOP (1000) 
	 [Relop_id]
	,[CapturedPlans_id]
	,[AvgRowSize]
	,[EstimateCPU]
	,[EstimateIO]
	,[EstimatedExecutionMode]
	,[EstimateRows]
	,[EstimatedRowsRead]
	,[LogicalOp]
	,[NodeId]
	,[Parallel]
	,[PhysicalOp]
	,[IsAdaptive]
	,[AdaptiveThresholdRows]
	,[EstimatedTotalSubtreeCost]
	,[TableCardinality]
	,[EstimateNumberOfExecutions]
	,[EstimateNumberOfRowsForAllExecutions]
FROM 
	[dbo].[Relop]
WHERE CapturedPlans_id = 1311
/*[dbo].[RunTimeCountersPerThread]*/
SELECT TOP (1000)
	 [RunTimeCountersPerThread_id]
	,[Relop_id]
	,[NodeId]
	,[Thread]
	,[ActualCPUms]
	,[ActualElapsedms]
	,[ActualEndOfScans]
	,[ActualExecutionMode]
	,[ActualExecutions]
	,[ActualPhysicalReads]
	,[ActualReadAheads]
	,[ActualRows]
	,[ActualRowsRead]
	,[ActualScans]
	,[Batches]
	,[InputMemoryGrant]
	,[IsInterleavedExecuted]
	,[OutputMemoryGrant]
	,[UsedMemoryGrant]
FROM 
	[dbo].[RunTimeCountersPerThread]
WHERE Relop_id IN (SELECT Relop_id FROM [dbo].[Relop] WHERE CapturedPlans_id = 1311)

SELECT TOP (1000) * FROM [dbo].[ParameterList] WHERE [Column] = '@ModifiedDate'

/*views*/
SELECT TOP (1000) * FROM [dbo].[vw_Converted_Plans]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_Overview]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_ColumnsWithNoStatistics]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_SpillToTempDb]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_SortSpillDetails] 
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_HashSpillDetails]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_Wait] /*Memory Grant Waittype is the only wait type in the plan <> WaitStats*/
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_PlanAffectingConvert]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_MemoryGrantWarning]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_NoJoinPredicate]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_UnmatchedIndexes]
SELECT TOP (1000) * FROM [dbo].[vw_ParameterList] WHERE QueryHash = '0x9219B95069442D28'
SELECT TOP (1000) * FROM [dbo].[vw_Actuals] WHERE perc1 > 1000 or perc1 = 0 /*overestimated*/ORDER BY CapturedPlans_id, perc1 
SELECT TOP (1000) * FROM [dbo].[vw_Actuals] WHERE perc1 < 0.1 AND perc1 <> 0 /*underestimated*/ORDER BY CapturedPlans_id, perc1 
SELECT TOP (1000) * FROM [dbo].[vw_Compile_TimeOut]
SELECT TOP (1000) * FROM [dbo].[vw_Multiple_Plans_Per_QueryHash] 
SELECT TOP (1000) * FROM [dbo].[vw_Duration] WHERE UdfCpuTime IS NOT NULL
SELECT TOP (1000) * FROM [dbo].[vw_QueryWithUdf]
SELECT TOP (1000) * FROM [dbo].[vw_Memory_PercentUsed] ORDER BY PercentageUsed 
SELECT TOP (1000) * FROM [dbo].[vw_MemoryGrantFeedbackAdjusted]
SELECT TOP (1000) * FROM [dbo].[vw_Missing_Index]
SELECT TOP (1000) * FROM [dbo].[vw_NonParallelPlanReason] WHERE [NonParallelPlanReason] = 'TSQLUserDefinedFunctionsNotParallelizable'
SELECT TOP (1000) * FROM [dbo].[vw_Parallel_Skew] WHERE [CapturedPlans_id] = 1311 AND [NodeId] = 1 ORDER BY Thread
SELECT TOP (1000) * FROM [dbo].[vw_Statistics_Not_Updated_Last_7_Days]
SELECT TOP (1000) * FROM [dbo].[vw_TraceFlags]