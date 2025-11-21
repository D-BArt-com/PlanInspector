/*views*/
SELECT TOP (1000) * FROM [dbo].[vw_Converted_Plans]
/*Warnings*/
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_Overview]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_ColumnsWithNoStatistics]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_SpillToTempDb]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_SortSpillDetails] ORDER BY WritesToTempDb DESC
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_HashSpillDetails] ORDER BY WritesToTempDb DESC
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_MemoryGrantWarning] ORDER BY GrantedMemory DESC
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_Wait] ORDER BY WaitTime DESC /*Memory Grant Waittype is the only wait type in the plan <> WaitStats*/
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_PlanAffectingConvert] ORDER BY ConvertIssue DESC /*"Cardinality Estimate" and "Seek Plan" are the only options*/
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_NoJoinPredicate]
SELECT TOP (1000) * FROM [dbo].[vw_PlanWarning_UnmatchedIndexes]
/*Parameters*/
SELECT TOP (1000) * FROM [dbo].[vw_ParameterList] ORDER BY CpuTime DESC
SELECT TOP (1000) * FROM [dbo].[vw_ParameterList] WHERE QueryHash = '0x9219B95069442D28'
/*actual vs estimate trouble*/
SELECT TOP (1000) * FROM [dbo].[vw_Actuals] WHERE perc1 > 1000 or perc1 = 0 /*overestimated*/ORDER BY perc1 DESC
SELECT TOP (1000) * FROM [dbo].[vw_Actuals] WHERE perc1 < 10 AND perc1 <> 0 /*underestimated*/ORDER BY  perc1 
/*duration*/
SELECT TOP (1000) * FROM [dbo].[vw_Compile_TimeOut]
SELECT TOP (1000) * FROM [dbo].[vw_Duration] ORDER BY CpuTime DESC
SELECT TOP (1000) * FROM [dbo].[vw_QueryWithUdf]
SELECT TOP (1000) * FROM [dbo].[vw_Memory_PercentUsed] WHERE GrantedMemory > 10240 ORDER BY PercentageUsed /* +10MB */
SELECT TOP (1000) * FROM [dbo].[vw_MemoryGrantFeedbackAdjusted]
/*missing indexes*/
SELECT TOP (1000) * FROM [dbo].[vw_Missing_Index]
/*parallelism*/
SELECT TOP (1000) * FROM [dbo].[vw_NonParallelPlanReason] ORDER BY  [NonParallelPlanReason] DESC
SELECT TOP (1000) * FROM [dbo].[vw_Parallel_Skew] WHERE [CapturedPlans_id] = 1311 AND [NodeId] = 1 ORDER BY Thread
/*Statistics*/
SELECT TOP (1000) * FROM [dbo].[vw_Statistics_Not_Updated_Last_7_Days] ORDER BY LastUpdate ASC
/*TraceFlags*/
SELECT TOP (1000) * FROM [dbo].[vw_TraceFlags]