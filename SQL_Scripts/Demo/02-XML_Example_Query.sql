/*Enable actual plan first*/
SELECT * FROM [DataTypes2017].[dbo].[Table_05] ORDER BY 1
GO
/*XML query to retrieve RelOp Elements*/	
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
	relop.value('@AvgRowSize','float') AS AvgRowSize,
	relop.value('@EstimateCPU','float') AS EstimateCPU,
	relop.value('@EstimateIO','float') AS EstimateIO,
	relop.value('@EstimateRebinds','float') AS EstimateRebinds,
	relop.value('@EstimateRewinds','float') AS EstimateRewinds,
	relop.value('@EstimatedExecutionMode','varchar(5)') AS EstimatedExecutionMode,
	relop.value('@GroupExecuted','bit') AS GroupExecuted,
	relop.value('@EstimateRows','float') AS EstimateRows,
	relop.value('@EstimateRowsWithoutRowGoal','float') AS EstimateRowsWithoutRowGoal,
	relop.value('@EstimatedRowsRead','float') AS EstimatedRowsRead,
	relop.value('@LogicalOp','varchar(32)') AS LogicalOp,
	relop.value('@NodeId','int') AS NodeId,
	relop.value('@Parallel','bit') AS Parallel,
	relop.value('@RemoteDataAccess','bit') AS RemoteDataAccess,
	relop.value('@Partitioned','bit') AS Partitioned,
	relop.value('@PhysicalOp','varchar(32)') AS PhysicalOp,
	relop.value('@IsAdaptive','bit') AS IsAdaptive,
	relop.value('@AdaptiveThresholdRows','float') AS AdaptiveThresholdRows,
	relop.value('@EstimatedTotalSubtreeCost','float') AS EstimatedTotalSubtreeCost,
	relop.value('@TableCardinality','float') AS TableCardinality,
	relop.value('@StatsCollectionId','int') AS StatsCollectionId,
	relop.value('@EstimatedJoinType','varchar(32)') AS EstimatedJoinType,
	relop.value('@HyperScaleOptimizedQueryProcessing','varchar(32)') AS HyperScaleOptimizedQueryProcessing,
	relop.value('@HyperScaleOptimizedQueryProcessingUnusedReason','varchar(32)') AS HyperScaleOptimizedQueryProcessingUnusedReason
FROM
	(
		SELECT
			try_convert(xml,showplan_xml) AS showplan_xml
		FROM 
			PlanUsageInfo.dbo.CapturedPlans
	) AS plans
	CROSS APPLY showplan_xml.nodes('//RelOp') AS t(relop)