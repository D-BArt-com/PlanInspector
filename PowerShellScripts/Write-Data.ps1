#==================================================================================================
#Function: Write query plan info to the database
#==================================================================================================
Function Write-DataTableToDatabase
{
  [CmdletBinding()]
  [OutputType([system.Data.DataTable])]
  Param
  (
    #Database where the output is written
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
    [string]$DbName,

    #Server where the output is written
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
    [string]$ServerName,
    
    #Schema of the table where the output is written
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
    [string]$Schema,

    #Table where the output is written
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
    [string]$TableOutput,

    #Datatable that is written to the database
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=0)]
    [data.datatable]$DataTable
  )
  try
  {
    $cn = new-object System.Data.SqlClient.SqlConnection("Data Source=$ServerName;Integrated Security=SSPI;Initial Catalog=$DbName")
    $cn.Open()
    $bc                      = new-object ("System.Data.SqlClient.SqlBulkCopy") $cn
    $bc.BulkCopyTimeout      = 600;
    $bc.BatchSize            = 1000
    $bc.DestinationTableName = "[$Schema].[$TableOutput]"
    $bc.WriteToServer($DataTable)
    $cn.Close()
  }
  catch
  {
    $cn.Close()
    $Error[0] | Format-List -force
    throw
  }
}
#==================================================================================================
#Function: Adjust estimate values in $DtRelop
#==================================================================================================
function Write-NestedLoopInfo ($Elements, $CapturedPlans_id)
{
  foreach($Element in $Elements)
  {
    #for a nested loop operator the estimated values must be calculated. 
    $IdRelop2                                  = $Element.Relop[1].NodeId
    [decimal]$EstimateNrOfExecutions           = $Element.Relop[0].EstimateRows #estimated nr of rows returned by the top input
    [decimal]$EstimateRows                     = $Element.Relop[1].EstimateRows #estimated nr of rows returned by the bottom inut
    [decimal]$EstimateNrOfRowsForAllExecutions = $EstimateNrOfExecutions * $EstimateRows 
    $DtIntermidiateRelop | Where-Object {($PsItem.CapturedPlans_id -eq $CapturedPlans_id) -and ($PsItem.nodeid -eq $IdRelop2)} | ForEach-Object {$PSItem.EstimateNumberOfExecutions = $EstimateNrOfExecutions} | Out-Null
    $DtIntermidiateRelop | Where-Object {($PsItem.CapturedPlans_id -eq $CapturedPlans_id) -and ($PsItem.nodeid -eq $IdRelop2)} | ForEach-Object {$PSItem.EstimateNumberOfRowsForAllExecutions = $EstimateNrOfRowsForAllExecutions}
  }
}
#==================================================================================================
#Function: Write parameter information to $DtParameterList
#==================================================================================================
function Write-ParameterList ($Elements, $CapturedPlans_id)
{
  foreach ($Element in $Elements)
  {
    [void]$DtParameterList.Rows.Add($null,$CapturedPlans_id, $Element.Column, $Element.ParameterDataType, $Element.ParameterCompiledValue, $Element.ParameterRuntimeValue)
  }
}  
#==================================================================================================
#Function: Write query plan information to $DtQueryPlan
#==================================================================================================
function Write-QueryPlan ($Element,$CapturedPlans_id)
{
  [void]$DtQueryPlan.Rows.Add($null,$CapturedPlans_id,$Element.DegreeOfParallelism, $Element.EffectiveDegreeOfParallelism, $Element.NonParallelPlanReason,
                              $Element.DOPFeedbackAdjusted, $Element.MemoryGrant, $Element.CachedPlanSize, $Element.CompileTime,
                              $Element.CompileCPU, $Element.CompileMemory, [System.boolean]$Element.UsePlan, [System.boolean]$Element.ContainsInterleavedExecutionCandidates,
                              [System.boolean]$Element.ContainsInlineScalarTsqlUdfs, $Element.QueryVariantID, $Element.DispatcherPlanHandle, [System.boolean]$Element.ExclusiveProfileTimeActive)
} 
#==================================================================================================
#Function: Write query plan information to $DtMemoryGrantInfo
#==================================================================================================
function Write-StatisticsInfo ($Element,$CapturedPlans_id)
{
  [void]$DtStatisticsInfo.Rows.Add($null, $CapturedPlans_id,$Element.Database, $Element.Schema, $Element.Table,$Element.Statistics,
                                   $Element.ModificationCount, [System.Decimal]$Element.SamplingPercent, $Element.LastUpdate)
}  
#==================================================================================================
#Function: Write query plan information to $DtMemoryGrantInfo
#==================================================================================================
function Write-MemoryGrantInfo ($Element,$CapturedPlans_id)
{
  [void]$DtMemoryGrantInfo.Rows.Add($null, $CapturedPlans_id,$Element.SerialRequiredMemory, $Element.SerialDesiredMemory, $Element.RequiredMemory,
                                    $Element.DesiredMemory, $Element.RequestedMemory, $Element.GrantWaitTime, $Element.GrantedMemory,
                                    $Element.MaxUsedMemory, $Element.MaxQueryMemory, $Element.LastRequestedMemory, $Element.IsMemoryGrantFeedbackAdjusted)

}  
#==================================================================================================
#Function: Write query plan information to $DtOptimizerHardwareDependentProperties
#==================================================================================================
function Write-OptimizerHardwareDependentProperties ($Element,$CapturedPlans_id)
{
  [void]$DtOptimizerHardwareDependentProperties.Rows.Add($null, $CapturedPlans_id,$Element.EstimatedAvailableMemoryGrant, $Element.EstimatedPagesCached,
                                                         $Element.EstimatedAvailableDegreeOfParallelism,$Element.MaxCompileMemory)
}  
#==================================================================================================
#Function: Write query plan information to $DtQueryPlan
#==================================================================================================
function Write-QueryTimeStats ($Element,$CapturedPlans_id)
{
  [void]$DtQueryTimeStats.Rows.Add($null, $CapturedPlans_id,$Element.CpuTime, $Element.ElapsedTime, $Element.UdfCpuTime, $Element.UdfElapsedTime)
}  
#==================================================================================================
#Function: Write query plan information to $DtWaitStats
#==================================================================================================
function Write-WaitStats ($Elements,$CapturedPlans_id)
{
  foreach ($Element in $Elements.ChildNodes)
  {
    [void]$DtWaitStats.Rows.Add($null, $CapturedPlans_id,$Element.WaitType, $Element.WaitTimeMs, $Element.WaitCount)
  }
}
#==================================================================================================
#Function: Write Basic statement information to $DtStmtSimple
#==================================================================================================
function Write-StmtSimple ($Element, $CapturedPlans_id)
{
  [void]$DtStmtSimple.Rows.Add($null, $CapturedPlans_id,$Element.StatementCompId,[double]$Element.StatementEstRows,$Element.StatementId,$Element.QueryCompilationReplay,
                              $Element.StatementOptmLevel, $Element.StatementOptmEarlyAbortReason, $Element.CardinalityEstimationModelVersion,
                              [double]$Element.StatementSubTreeCost, $Element.StatementText, $Element.StatementType,$Element.TemplatePlanGuideDB,
                              $Element.TemplatePlanGuideName, $Element.PlanGuideDB, $Element.PlanGuideName, $Element.ParameterizedText,
                              $Element.ParameterizedPlanHandle, $Element.QueryHash, $Element.QueryPlanHash, $Element.RetrievedFromCache,
                              $Element.StatementSqlHandle, $Element.DatabaseContextSettingsId, $Element.ParentObjectId,$Element.BatchSqlHandle,
                              $Element.StatementParameterizationType, [System.Boolean]$Element.SecurityPolicyApplied,
                              [System.Boolean]$Element.BatchModeOnRowStoreUsed,$Element.QueryStoreStatementHintId,$Element.QueryStoreStatementHintText,
                              $Element.QueryStoreStatementHintSource, [System.Boolean]$Element.ContainsLedgerTables)
}  
#==================================================================================================
#Function: Write warnings
#==================================================================================================
function Write-Warnings ($Elements, $CapturedPlans_id)
{
  foreach ($Element in $Elements.ChildNodes)
  {
    Switch ($Element.Name)
    {
        'ColumnsWithNoStatistics'    {Write-PlanWarningColumnReference $Element $DtPlanWarnings $CapturedPlans_id 'ColumnsWithNoStatistics';break}
        'ColumnsWithStaleStatistics' {Write-PlanWarning $Element $DtPlanWarnings $CapturedPlans_id 'ColumnsWithStaleStatistics' ;break}
        'ExchangeSpillDetails'       {Write-PlanWarning $Element $DtPlanWarnings $CapturedPlans_id 'ExchangeSpillDetails' ;break}
        'HashSpillDetails'           {Write-PlanWarning $Element $DtPlanWarnings $CapturedPlans_id 'HashSpillDetails'; break}
        'MemoryGrantWarning'         {Write-PlanWarning $Element $DtPlanWarnings $CapturedPlans_id 'MemoryGrantWarning';break}
        'PlanAffectingConvert'       {Write-PlanWarning $Element $DtPlanWarnings $CapturedPlans_id 'PlanAffectingConvert';break}
        'SortSpillDetails'           {Write-PlanWarning $Element $DtPlanWarnings $CapturedPlans_id 'SortSpillDetails';break}
        'SpillToTempDb'              {Write-PlanWarning $Element $DtPlanWarnings $CapturedPlans_id 'SpillToTempDb';break}
        'Wait'                       {Write-PlanWarning $Element $DtPlanWarnings $CapturedPlans_id 'Wait';break}
        'SpillOccurred'              {Write-PlanWarning $Element $DtPlanWarnings $CapturedPlans_id 'SpillOccurred';break}
        default                      {Write-Output "$CapturedPlans_id  Check warning $($Element.Name)";throw} 
    }
  }
  if ($Elements.NoJoinPredicate -eq 1)
  {
    $arrayrow                     = $DtPlanWarnings.NewRow()
    $arrayrow["id"]               = [DBNull]::Value
    $arrayrow["CapturedPlans_id"] = $CapturedPlans_id  
    $KeyName                      = ('IsNoJoinPredicate')
    $arrayrow[$keyName]           = $true
    [void]$DtPlanWarnings.Rows.Add($arrayrow)
  }
  if ($Elements.UnmatchedIndexes -eq 1)
  {
    $UnmatechedIndexes = $Plan.GetElementsByTagName('UnmatchedIndexes')
    foreach ($UnmatechedIndex in $UnmatechedIndexes)
    { 
      #the element type that we're looking for with unmatched indexes = ObjectType
      Write-PlanWarningObject $UnmatechedIndex $DtPlanWarnings $CapturedPlans_id 'UnmatchedIndexes'
    }
  }
  elseif (($Elements.SpatialGuess -eq 1) -or ($Elements.FullUpdateForOnlineIndexBuild -eq 1))
  {
    Write-Error 'check the warnings section of this plan'
  }
}  
#==================================================================================================
#Function: Write query plan information to $DtQueryPlan
#==================================================================================================
function Write-Relop ($Element,$CapturedPlans_id, $Relop_id)
{
  try 
  {
    [void]$DtIntermidiateRelop.Rows.Add($Relop_id,$CapturedPlans_id, [double]$Element.AvgRowSize,
    [double]$Element.EstimateCPU,
    [double]$Element.EstimateIO,
    [double]$Element.EstimateRebinds,
    [double]$Element.EstimateRewinds,
    $Element.EstimatedExecutionMode,
    [System.Boolean]$Element.GroupExecuted,
    [double]$Element.EstimateRows,
    [double]$Element.EstimateRowsWithoutRowGoal,
    [double]$Element.EstimatedRowsRead,
    $Element.LogicalOp,
    $Element.NodeId,
    [System.Boolean]$Element.Parallel,
    [System.Boolean]$Element.RemoteDataAccess,
    [System.Boolean]$Element.Partitioned,
    $Element.PhysicalOp,
    [System.Boolean]$Element.IsAdaptive,
    [double]$Element.AdaptiveThresholdRows,
    [double]$Element.EstimatedTotalSubtreeCost,
    [double]$Element.TableCardinality,
    $Element.StatsCollectionId,
    $Element.EstimatedJoinType,
    $Element.HyperScaleOptimizedQueryProcessing,
    $Element.HyperScaleOptimizedQueryProcessingUnusedReason)
  }
  catch 
  {
    Write-Output ($Error[0] | Format-List -force)
    throw
  }
} 
#==================================================================================================
#Function: Write query plan information to $DtQueryPlan
#==================================================================================================
function Write-RuntimeInformation ($Element,$Relop_id)
{
  $CountPerThreads = $Element.RunTimeInformation.RunTimeCountersPerThread
  foreach ($Cpt in $CountPerThreads)
  {   
    [void]$DtRunTimeCountersPerThread.Rows.Add($null,$Relop_id,$Cpt.ActualCPUms, $Cpt.ActualElapsedms, $Cpt.ActualEndOfScans, $Cpt.ActualExecutionMode, $Cpt.ActualExecutions, $Cpt.ActualJoinType,
                                               $Cpt.ActualLobLogicalReads, $Cpt.ActualLobPageServerReadAheads, $Cpt.ActualLobPageServerReads, $Cpt.ActualLobPhysicalReads,
                                               $Cpt.ActualLobReadAheads, $Cpt.ActualLocallyAggregatedRows, $ActualLogicalReads , $Cpt.ActualPageServerPushedPageIDs,
                                               $Cpt.ActualPageServerPushedReads, $Cpt.ActualPageServerReadAheads, $Cpt.ActualPageServerReads, $Cpt.ActualPageServerRowsRead,
                                               $Cpt.ActualPageServerRowsReturned, $Cpt.ActualPhysicalReads, $Cpt.ActualReadAheads, $Cpt.ActualRebinds, $Cpt.ActualRewinds,
                                               $Cpt.ActualRows, $Cpt.ActualRowsRead, $Cpt.ActualScans, $Cpt.Batches, $Cpt.BrickId, $Cpt.CloseTime, $Cpt.FirstActiveTime,
                                               $Cpt.FirstRowTime, $Cpt.HpcDeviceToHostBytes, $Cpt.HpcHostToDeviceBytes, $Cpt.HpcKernelElapsedUs, $Cpt.HpcRowCount,
                                               $Cpt.InputMemoryGrant, [System.Boolean]$Cpt.IsInterleavedExecuted, $Cpt.LastActiveTime, $Cpt.LastRowTime, $Element.NodeId, $Cpt.OpenTime,
                                               $Cpt.OutputMemoryGrant, $Cpt.RowRequalifications, $Cpt.SchedulerId, $Cpt.SegmentReads, $Cpt.SegmentSkips, $Cpt.TaskAddr,$Cpt.Thread,
                                               $Cpt.UsedMemoryGrant)
  }
}  
#==================================================================================================
#Function: Write plan warning to $Dt
#==================================================================================================
function Write-PlanWarning ($Element, $Dt, $CapturedPlans_id, $WarningName)
{
  $arrayrow                     = $Dt.NewRow()
  $arrayrow["id"]               = [DBNull]::Value
  $arrayrow["CapturedPlans_id"] = $CapturedPlans_id  
  foreach ($key in $Element.Attributes)
  {
    try 
    {
      $arrayrow[$key.Name] = $key.Value
    }
    catch 
    {
      throw
    }
  }
  $KeyName            = ('Is' + $WarningName)
  $arrayrow[$keyName] = $true
  [void]$Dt.Rows.Add($arrayrow)
}
#==================================================================================================
#Function: Check for a null value and adjust
#==================================================================================================
Function Test-Null ($Value)
{
  try
  {
    Switch ($Value)
    {
      $null   {break}
      default {$Value = $Value.Replace('[','').Replace(']','');break}
    }
  }
  catch
  {
    throw
  }
  Return $Value
}
#==================================================================================================
#Function: Write plan warning with a column reference to a $Dt ('ColumnsWithNoStatistics')
#==================================================================================================
function Write-PlanWarningColumnReference  ($Element, $Dt, $CapturedPlans_id, $WarningName)
{
  $ColumnReferences = $Element.GetElementsByTagName('ColumnReference')
  foreach($ColumnReference in $ColumnReferences)
  {
    $arrayrow                     = $Dt.NewRow()
    $arrayrow["id"]               = [DBNull]::Value
    $arrayrow["CapturedPlans_id"] = $CapturedPlans_id  
    try 
    {
      $arrayrow["Database"] = Test-Null $ColumnReference.Database
      $arrayrow["Schema"]   = Test-Null $ColumnReference.Schema
      $arrayrow["Table"]    = Test-Null $ColumnReference.Table       
      $arrayrow["Alias"]    = Test-Null $ColumnReference.Alias
      $arrayrow["Column"]   = $ColumnReference.Column.Replace('[','').Replace(']','') #is required, no need for testing
      
      if($null -ne $ColumnReference.ComputedColumn)
      {
        $arrayrow["ComputedColumn"] = $ColumnReference.ComputedColumn
      }
      else 
      {
        $arrayrow["ComputedColumn"] = [DBNull]::Value
      }
      $arrayrow["ParameterDataType"]      = $ColumnReference.ParameterDataType
      $arrayrow["ParameterCompiledValue"] = $ColumnReference.ParameterCompiledValue
      $arrayrow["ParameterRuntimeValue"]  = $ColumnReference.ParameterRuntimeValue
    }
    catch 
    {
      throw
    }
    $KeyName            = ('Is' + $WarningName)
    $arrayrow[$keyName] = $true
    [void]$Dt.Rows.Add($arrayrow)
  }
} 
#==================================================================================================
#Function: Write plan warning with a object reference to a $Dt ('UnmatchedIndexes')
#==================================================================================================
function Write-PlanWarningObject  ($Element, $Dt, $CapturedPlans_id, $WarningName)
{
  $Objects = $Element.GetElementsByTagName('Object')
  foreach($Object in $Objects)
  {
    $arrayrow                     = $Dt.NewRow()
    $arrayrow["id"]               = [DBNull]::Value
    $arrayrow["CapturedPlans_id"] = $CapturedPlans_id  
    try 
    {
      $arrayrow["Server"]   = Test-Null $Object.Server
      $arrayrow["Database"] = Test-Null $Object.Database
      $arrayrow["Schema"]   = Test-Null $Object.Schema
      $arrayrow["Table"]    = Test-Null $Object.Table       
      $arrayrow["Index"]    = Test-Null $Object.Index
    }
    catch 
    {
      throw
    }
    $KeyName            = ('Is' + $WarningName)
    $arrayrow[$keyName] = $true
    [void]$Dt.Rows.Add($arrayrow)
  }
} 
#==================================================================================================
#Read variables from xml file
#==================================================================================================
try
{
  $XmlLocation    = ".\PowerShellScripts\Variables.xml"
  [xml]$Variables = Get-Content $XmlLocation -ErrorAction Stop
  $ServerName     = $Variables.General.ServerName
  $DbName         = $Variables.General.DbName
  $TableAPLans    = $Variables.General.TableName
}
catch
{
  $Error[0] | Format-List -force
  throw
}
#==================================================================================================
#Set Culture.
#==================================================================================================
try
{
  Set-Culture -CultureInfo en-US #to match comma and thousand seperators from SQL Server.
}
catch
{
  $Error[0] | Format-List -force
  throw
}
#==================================================================================================
#Create datatable $DtStmtSimple.
#==================================================================================================
$DtStmtSimple = New-Object system.Data.DataTable
[void]$DtStmtSimple.Columns.Add("id"                               , "System.int64")
[void]$DtStmtSimple.Columns.Add("CapturedPlans_id"                 , "System.int64")
[void]$DtStmtSimple.Columns.Add("StatementCompId"                  , "System.int64")
[void]$DtStmtSimple.Columns.Add("StatementEstRows"                 , "System.double")
[void]$DtStmtSimple.Columns.Add("StatementId"                      , "System.int64")
[void]$DtStmtSimple.Columns.Add("QueryCompilationReplay"           , "System.int64")
[void]$DtStmtSimple.Columns.Add("StatementOptmLevel"               , "System.String")
[void]$DtStmtSimple.Columns.Add("StatementOptmEarlyAbortReason"    , "System.String")
[void]$DtStmtSimple.Columns.Add("CardinalityEstimationModelVersion", "System.String")
[void]$DtStmtSimple.Columns.Add("StatementSubTreeCost"             , "System.double")
[void]$DtStmtSimple.Columns.Add("StatementText"                    , "System.String")
[void]$DtStmtSimple.Columns.Add("StatementType"                    , "System.String")
[void]$DtStmtSimple.Columns.Add("TemplatePlanGuideDB"              , "System.String")
[void]$DtStmtSimple.Columns.Add("TemplatePlanGuideName"            , "System.String")
[void]$DtStmtSimple.Columns.Add("PlanGuideDB"                      , "System.String")
[void]$DtStmtSimple.Columns.Add("PlanGuideName"                    , "System.String")
[void]$DtStmtSimple.Columns.Add("ParameterizedText"                , "System.String")
[void]$DtStmtSimple.Columns.Add("ParameterizedPlanHandle"          , "System.String")
[void]$DtStmtSimple.Columns.Add("QueryHash"                        , "System.String")
[void]$DtStmtSimple.Columns.Add("QueryPlanHash"                    , "System.String")
[void]$DtStmtSimple.Columns.Add("RetrievedFromCache"               , "System.String")
[void]$DtStmtSimple.Columns.Add("StatementSqlHandle"               , "System.String")
[void]$DtStmtSimple.Columns.Add("DatabaseContextSettingsId"        , "System.int64")
[void]$DtStmtSimple.Columns.Add("ParentObjectId"                   , "System.int64")
[void]$DtStmtSimple.Columns.Add("BatchSqlHandle"                   , "System.String")
[void]$DtStmtSimple.Columns.Add("StatementParameterizationType"    , "System.int64")
[void]$DtStmtSimple.Columns.Add("SecurityPolicyApplied"            , "System.boolean")
[void]$DtStmtSimple.Columns.Add("BatchModeOnRowStoreUsed"          , "System.boolean")
[void]$DtStmtSimple.Columns.Add("QueryStoreStatementHintId"        , "System.int64")
[void]$DtStmtSimple.Columns.Add("QueryStoreStatementHintText"      , "System.String")
[void]$DtStmtSimple.Columns.Add("QueryStoreStatementHintSource"    , "System.String")
[void]$DtStmtSimple.Columns.Add("ContainsLedgerTables"             , "System.boolean")
#==================================================================================================
#Create datatable $DtStatementSetOptions.
#==================================================================================================
$DtStatementSetOptions = New-Object system.Data.DataTable
[void]$DtStatementSetOptions.Columns.Add("StatementSetOptions_id" , "System.int64")
[void]$DtStatementSetOptions.Columns.Add("CapturedPlans_id"       , "System.int64")
[void]$DtStatementSetOptions.Columns.Add("ANSI_NULLS"             , "System.boolean")
[void]$DtStatementSetOptions.Columns.Add("ANSI_PADDING"           , "System.boolean")
[void]$DtStatementSetOptions.Columns.Add("ANSI_WARNINGS"          , "System.boolean")
[void]$DtStatementSetOptions.Columns.Add("ARITHABORT"             , "System.boolean")
[void]$DtStatementSetOptions.Columns.Add("CONCAT_NULL_YIELDS_NULL", "System.boolean")
[void]$DtStatementSetOptions.Columns.Add("NUMERIC_ROUNDABORT"     , "System.boolean")
[void]$DtStatementSetOptions.Columns.Add("QUOTED_IDENTIFIER"      , "System.boolean")
#==================================================================================================
#Create datatable $DtQueryPlan.
#==================================================================================================
$DtQueryPlan = New-Object system.Data.DataTable
[void]$DtQueryPlan.Columns.Add("QueryPlan_id"                          , "System.int64")
[void]$DtQueryPlan.Columns.Add("CapturedPlans_id"                      , "System.int64")
[void]$DtQueryPlan.Columns.Add("DegreeOfParallelism"                   , "System.int64")
[void]$DtQueryPlan.Columns.Add("EffectiveDegreeOfParallelism"          , "System.int64")
[void]$DtQueryPlan.Columns.Add("NonParallelPlanReason"                 , "System.string")
[void]$DtQueryPlan.Columns.Add("DOPFeedbackAdjusted"                   , "System.string")
[void]$DtQueryPlan.Columns.Add("MemoryGrant"                           , "System.int64")
[void]$DtQueryPlan.Columns.Add("CachedPlanSize"                        , "System.int64")
[void]$DtQueryPlan.Columns.Add("CompileTime"                           , "System.int64")
[void]$DtQueryPlan.Columns.Add("CompileCPU"                            , "System.int64")
[void]$DtQueryPlan.Columns.Add("CompileMemory"                         , "System.int64")
[void]$DtQueryPlan.Columns.Add("UsePlan"                               , "System.boolean")
[void]$DtQueryPlan.Columns.Add("ContainsInterleavedExecutionCandidates", "System.boolean")
[void]$DtQueryPlan.Columns.Add("ContainsInlineScalarTsqlUdfs"          , "System.boolean")
[void]$DtQueryPlan.Columns.Add("QueryVariantID"                        , "System.int64")
[void]$DtQueryPlan.Columns.Add("DispatcherPlanHandle"                  , "System.string")
[void]$DtQueryPlan.Columns.Add("ExclusiveProfileTimeActive"            , "System.boolean")
#==================================================================================================
#Create datatable $DtPlanWarnings.
#==================================================================================================
$DtPlanWarnings = New-Object system.Data.DataTable
[void]$DtPlanWarnings.Columns.Add("id"                          , "System.int64")
[void]$DtPlanWarnings.Columns.Add("CapturedPlans_id"            , "System.Int32")
[void]$DtPlanWarnings.Columns.Add("IsColumnsWithNoStatistics"   , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsColumnsWithStaleStatistics", "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsExchangeSpillDetails"      , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsHashSpillDetails"          , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsMemoryGrantWarning"        , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsNoJoinPredicate"           , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsPlanAffectingConvert"      , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsSortSpillDetails"          , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsSpillOccurred"             , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsSpillToTempDb"             , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsUnmatchedIndexes"          , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("IsWait"                      , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("Server"                      , "System.String")
[void]$DtPlanWarnings.Columns.Add("Database"                    , "System.String")
[void]$DtPlanWarnings.Columns.Add("Schema"                      , "System.String")
[void]$DtPlanWarnings.Columns.Add("Table"                       , "System.String")
[void]$DtPlanWarnings.Columns.Add("Alias"                       , "System.String")
[void]$DtPlanWarnings.Columns.Add("Index"                       , "System.String")
[void]$DtPlanWarnings.Columns.Add("Column"                      , "System.String")
[void]$DtPlanWarnings.Columns.Add("ComputedColumn"              , "System.Boolean")
[void]$DtPlanWarnings.Columns.Add("ParameterDataType"           , "System.String")
[void]$DtPlanWarnings.Columns.Add("ParameterCompiledValue"      , "System.String")
[void]$DtPlanWarnings.Columns.Add("ParameterRuntimeValue"       , "System.String")
[void]$DtPlanWarnings.Columns.Add("ConvertIssue"                , "System.String")
[void]$DtPlanWarnings.Columns.Add("Expression"                  , "System.String")
[void]$DtPlanWarnings.Columns.Add("GrantWarningKind"            , "System.string")
[void]$DtPlanWarnings.Columns.Add("RequestedMemory"             , "System.int64")
[void]$DtPlanWarnings.Columns.Add("GrantedMemory"               , "System.int64")
[void]$DtPlanWarnings.Columns.Add("MaxUsedMemory"               , "System.int64")
[void]$DtPlanWarnings.Columns.Add("SpillLevel"                  , "System.int64")
[void]$DtPlanWarnings.Columns.Add("SpilledThreadCount"          , "System.int64")
[void]$DtPlanWarnings.Columns.Add("GrantedMemoryKb"             , "System.int64")
[void]$DtPlanWarnings.Columns.Add("UsedMemoryKb"                , "System.int64")
[void]$DtPlanWarnings.Columns.Add("WritesToTempDb"              , "System.int64")
[void]$DtPlanWarnings.Columns.Add("ReadsFromTempDb"             , "System.int64")
[void]$DtPlanWarnings.Columns.Add("WaitType"                    , "System.string")
[void]$DtPlanWarnings.Columns.Add("WaitTime"                    , "System.int64")
[void]$DtPlanWarnings.Columns.Add("Detail"                      , "System.Boolean")
#==================================================================================================
#Create datatable $DtMissingIndex.
#==================================================================================================
$DtMissingIndex = New-Object system.Data.DataTable
[void]$DtMissingIndex.Columns.Add("CapturedPlans_id" , "System.int64")
#==================================================================================================
#Create datatable $DtMemoryGrantInfo.
#==================================================================================================
$DtMemoryGrantInfo = New-Object system.Data.DataTable
[void]$DtMemoryGrantInfo.Columns.Add("id"                           , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("CapturedPlans_id"             , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("SerialRequiredMemory"         , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("SerialDesiredMemory"          , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("RequiredMemory"               , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("DesiredMemory"                , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("RequestedMemory"              , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("GrantWaitTime"                , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("GrantedMemory"                , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("MaxUsedMemory"                , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("MaxQueryMemory"               , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("LastRequestedMemory"          , "System.int64")
[void]$DtMemoryGrantInfo.Columns.Add("IsMemoryGrantFeedbackAdjusted", "System.string")
#==================================================================================================
#Create datatable OptimizerHardwareDependentProperties.
#==================================================================================================
$DtOptimizerHardwareDependentProperties = New-Object system.Data.DataTable
[void]$DtOptimizerHardwareDependentProperties.Columns.Add("id"                                   , "System.int64")
[void]$DtOptimizerHardwareDependentProperties.Columns.Add("CapturedPlans_id"                     , "System.int64")
[void]$DtOptimizerHardwareDependentProperties.Columns.Add("EstimatedAvailableMemoryGrant"        , "System.int64")
[void]$DtOptimizerHardwareDependentProperties.Columns.Add("EstimatedPagesCached"                 , "System.int64")
[void]$DtOptimizerHardwareDependentProperties.Columns.Add("EstimatedAvailableDegreeOfParallelism", "System.int32")
[void]$DtOptimizerHardwareDependentProperties.Columns.Add("MaxCompileMemory"                     , "System.int64")
#==================================================================================================
#Create datatable $DtStatisticsInfo.
#==================================================================================================
$DtStatisticsInfo = New-Object system.Data.DataTable
[void]$DtStatisticsInfo.Columns.Add("id"               , "System.int64")
[void]$DtStatisticsInfo.Columns.Add("CapturedPlans_id" , "System.Int32")
[void]$DtStatisticsInfo.Columns.Add("Database"         , "System.String")
[void]$DtStatisticsInfo.Columns.Add("Schema"           , "System.String")
[void]$DtStatisticsInfo.Columns.Add("Table"            , "System.String")
[void]$DtStatisticsInfo.Columns.Add("Statistics"       , "System.String")
[void]$DtStatisticsInfo.Columns.Add("ModificationCount", "System.int64")
[void]$DtStatisticsInfo.Columns.Add("SamplingPercent"  , "System.decimal")
[void]$DtStatisticsInfo.Columns.Add("LastUpdate"       , "System.DateTime")
#==================================================================================================
#Create datatable $DtTraceFlag.
#==================================================================================================
$DtTraceFlag = New-Object system.Data.DataTable
[void]$DtTraceFlag.Columns.Add("id"              , "System.int64")
[void]$DtTraceFlag.Columns.Add("CapturedPlans_id", "System.int64")
[void]$DtTraceFlag.Columns.Add("Value"           , "System.int64")
[void]$DtTraceFlag.Columns.Add("Scope"           , "System.String")
#==================================================================================================
#Create datatable $DtWaitStats.
#==================================================================================================
$DtWaitStats = New-Object system.Data.DataTable
[void]$DtWaitStats.Columns.Add("id"              , "System.int64")
[void]$DtWaitStats.Columns.Add("CapturedPlans_id", "System.int64")
[void]$DtWaitStats.Columns.Add("WaitType"        , "System.String")
[void]$DtWaitStats.Columns.Add("WaitTimeMs"      , "System.int64")
[void]$DtWaitStats.Columns.Add("WaitCount"       , "System.int64")
#==================================================================================================
#Create datatable $DtQueryTimeStats.
#==================================================================================================
$DtQueryTimeStats = New-Object system.Data.DataTable
[void]$DtQueryTimeStats.Columns.Add("id"              , "System.int64")
[void]$DtQueryTimeStats.Columns.Add("CapturedPlans_id", "System.int64")
[void]$DtQueryTimeStats.Columns.Add("CpuTime"         , "System.int64")
[void]$DtQueryTimeStats.Columns.Add("ElapsedTime"     , "System.int64")
[void]$DtQueryTimeStats.Columns.Add("UdfCpuTime"      , "System.int64")
[void]$DtQueryTimeStats.Columns.Add("UdfElapsedTime"  , "System.int64")
#==================================================================================================
#Create datatable $DtRelop.
#==================================================================================================
$DtRelop = New-Object system.Data.DataTable
[void]$DtRelop.Columns.Add("id"                                            , "System.int64")
[void]$DtRelop.Columns.Add("CapturedPlans_id"                              , "System.int64")
[void]$DtRelop.Columns.Add("AvgRowSize"                                    , "System.double")
[void]$DtRelop.Columns.Add("EstimateCPU"                                   , "System.double")
[void]$DtRelop.Columns.Add("EstimateIO"                                    , "System.double")
[void]$DtRelop.Columns.Add("EstimateRebinds"                               , "System.double")
[void]$DtRelop.Columns.Add("EstimateRewinds"                               , "System.double")
[void]$DtRelop.Columns.Add("EstimatedExecutionMode"                        , "System.String")
[void]$DtRelop.Columns.Add("GroupExecuted"                                 , "System.boolean")
[void]$DtRelop.Columns.Add("EstimateRows"                                  , "System.double")
[void]$DtRelop.Columns.Add("EstimateRowsWithoutRowGoal"                    , "System.double")
[void]$DtRelop.Columns.Add("EstimatedRowsRead"                             , "System.double")
[void]$DtRelop.Columns.Add("LogicalOp"                                     , "System.String")
[void]$DtRelop.Columns.Add("NodeId"                                        , "System.int32")
[void]$DtRelop.Columns.Add("Parallel"                                      , "System.boolean")
[void]$DtRelop.Columns.Add("RemoteDataAccess"                              , "System.boolean")
[void]$DtRelop.Columns.Add("Partitioned"                                   , "System.boolean")
[void]$DtRelop.Columns.Add("PhysicalOp"                                    , "System.String")
[void]$DtRelop.Columns.Add("IsAdaptive"                                    , "System.boolean")
[void]$DtRelop.Columns.Add("AdaptiveThresholdRows"                         , "System.double")
[void]$DtRelop.Columns.Add("EstimatedTotalSubtreeCost"                     , "System.double")
[void]$DtRelop.Columns.Add("TableCardinality"                              , "System.double")
[void]$DtRelop.Columns.Add("StatsCollectionId"                             , "System.int64")
[void]$DtRelop.Columns.Add("EstimatedJoinType"                             , "System.String")
[void]$DtRelop.Columns.Add("HyperScaleOptimizedQueryProcessing"            , "System.String")
[void]$DtRelop.Columns.Add("HyperScaleOptimizedQueryProcessingUnusedReason", "System.String")
[void]$DtRelop.Columns.Add("EstimateNumberOfExecutions"                    , "System.double")
[void]$DtRelop.Columns.Add("EstimateNumberOfRowsForAllExecutions"          , "System.double")
#==================================================================================================
#Create datatable $DtIntermidiateRelop.
#==================================================================================================
$DtIntermidiateRelop = $DtRelop.Clone()
#==================================================================================================
#Create datatable $DtRunTimeCountersPerThread.
#==================================================================================================
$DtRunTimeCountersPerThread = New-Object system.Data.DataTable
[void]$DtRunTimeCountersPerThread.Columns.Add("id"                           , "System.int64")
[void]$DtRunTimeCountersPerThread.Columns.Add("CapturedPlans_id"             , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualCPUms"                  , "System.Decimal")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualElapsedms"              , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualEndOfScans"             , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualExecutionMode"          , "System.String")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualExecutions"             , "System.Decimal")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualJoinType"               , "System.String")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualLobLogicalReads"        , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualLobPageServerReadAheads", "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualLobPageServerReads"     , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualLobPhysicalReads"       , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualLobReadAheads"          , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualLocallyAggregatedRows"  , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualLogicalReads"           , "System.decimal")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualPageServerPushedPageIDs", "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualPageServerPushedReads"  , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualPageServerReadAheads"   , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualPageServerReads"        , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualPageServerRowsRead"     , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualPageServerRowsReturned" , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualPhysicalReads"          , "System.Decimal")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualReadAheads"             , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualRebinds"                , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualRewinds"                , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualRows"                   , "System.Decimal")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualRowsRead"               , "System.Decimal")
[void]$DtRunTimeCountersPerThread.Columns.Add("ActualScans"                  , "System.Decimal")
[void]$DtRunTimeCountersPerThread.Columns.Add("Batches"                      , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("BrickId"                      , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("CloseTime"                    , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("FirstActiveTime"              , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("FirstRowTime"                 , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("HpcDeviceToHostBytes"         , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("HpcHostToDeviceBytes"         , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("HpcKernelElapsedUs"           , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("HpcRowCount"                  , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("InputMemoryGrant"             , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("IsInterleavedExecuted"        , "System.Boolean")
[void]$DtRunTimeCountersPerThread.Columns.Add("LastActiveTime"               , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("LastRowTime"                  , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("NodeId"                       , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("OpenTime"                     , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("OutputMemoryGrant"            , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("RowRequalifications"          , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("SchedulerId"                  , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("SegmentReads"                 , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("SegmentSkips"                 , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("TaskAddr"                     , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("Thread"                       , "System.Int32")
[void]$DtRunTimeCountersPerThread.Columns.Add("UsedMemoryGrant"              , "System.Int32")
#==================================================================================================
#Create datatable $DtParameterList.
#==================================================================================================
$DtParameterList = New-Object system.Data.DataTable
[void]$DtParameterList.Columns.Add("id"                    , "System.int64")
[void]$DtParameterList.Columns.Add("CapturedPlans_id"      , "System.int64")
[void]$DtParameterList.Columns.Add("Column"                , "System.String")
[void]$DtParameterList.Columns.Add("ParameterDataType"     , "System.String")
[void]$DtParameterList.Columns.Add("ParameterCompiledValue", "System.String")
[void]$DtParameterList.Columns.Add("ParameterRuntimeValue" , "System.String")
#==================================================================================================
#Get the plans from $DbName.
#==================================================================================================
$Query = "SELECT
             [showplan_xml]
            ,[CapturedPlans_id]
          FROM 
            $TableAPLans"
Write-Output ("Start retrieve data from db " + (Get-Date))
try  
{
  $cn = new-object System.Data.SqlClient.SqlConnection("Data Source=$ServerName;Integrated Security=SSPI;Initial Catalog=$DbName")
  $cn.Open()
  $command                = $cn.CreateCommand()
  $command.CommandText    = $Query
  $command.CommandTimeout = 0
  $Result                 = $command.ExecuteReader()
  $Results                = New-Object "System.Data.Datatable"
  $Results.Load($Result)
  $cn.Close()
  $Results = $Results | Where-Object {$PsItem.query_plan -notlike  "*query_store_runtime_stats*" -and $PsItem.query_plan -notlike "*dm_exec_sql_text*" -and $PsItem.execution_count -ne [dbnull]::Value } 
}
catch 
{
  throw
}
$StartTime = Get-Date
Write-Output ("End of data retrieval, start plan processing  " + (Get-Date))
#==================================================================================================
#Loop trough the results.
#==================================================================================================
$Relop_id = 1 #RunTimeCountersPerThread is a subtable of Relop, keep count of the PK of the Relop table to reference from RunTimeCountersPerThread
foreach($Result in $Results)
{
  try
  {
    [Xml]$Plan        = $Result.showplan_xml
    $CapturedPlans_id = $Result.CapturedPlans_id
    #==================================================================================================
    #Write basic statement info to $DtStmtSimple.
    #==================================================================================================
    $Elements  = $Plan.GetElementsByTagName('StmtSimple')
    foreach ($Element in $Elements)
    {
      Write-StmtSimple $Element $CapturedPlans_id
    }
    #==================================================================================================
    #Write StatementSetOptions info to $DtStatementSetOptions.
    #==================================================================================================
    $Element = $Plan.GetElementsByTagName('StatementSetOptions')
    if($Element.Count -gt 0)
    {
      [void]$DtStatementSetOptions.Rows.Add($null, $CapturedPlans_id, $Element.ANSI_NULLS, $Element.ANSI_PADDING, 
                                            $Element.ANSI_WARNINGS, $Element.ARITHABORT, $Element.CONCAT_NULL_YIELDS_NULL, 
                                            $Element.NUMERIC_ROUNDABORT, $Element.QUOTED_IDENTIFIER)
    }
    #==================================================================================================
    #Write Query plan info to $DtQueryPlan.
    #==================================================================================================
    $Elements = $Plan.GetElementsByTagName('QueryPlan')
    foreach ($Element in $Elements)
    {
      Write-QueryPlan $Element $CapturedPlans_id
    }
    #==================================================================================================
    #Write basic statement info to $DtStmtSimple.
    #==================================================================================================
    $Elements  = $Plan.GetElementsByTagName('MissingIndex')
    if($Elements.Count -gt 0)
    {
      [void]$DtMissingIndex.Rows.Add($CapturedPlans_id)
    }
    #==================================================================================================
    #Get Warnings from the plan.
    #==================================================================================================
    $Elements = $Plan.GetElementsByTagName('Warnings')
    if($Elements.Count -gt 0)
    {
      Write-Warnings $Elements $CapturedPlans_id
    }
    #==================================================================================================
    #Write MemoryGrantInfo to $DtMemoryGrantInfo.
    #==================================================================================================
    $Elements = $Plan.GetElementsByTagName('MemoryGrantInfo')
    foreach ($Element in $Elements)
    {
      Write-MemoryGrantInfo $Element $CapturedPlans_id
    }
    #==================================================================================================
    #Write OptimizerHardwareDependentProperties to $DtOptimizerHardwareDependentPropertiesType.
    #==================================================================================================
    $Elements = $Plan.GetElementsByTagName('OptimizerHardwareDependentProperties')
    foreach ($Element in $Elements)
    {
      Write-OptimizerHardwareDependentProperties $Element $CapturedPlans_id
    }
    #==================================================================================================
    #Write MemoryGrantInfo to $DtStatisticsInfo.
    #==================================================================================================
    $OptimizerStatsUsage = $Plan.GetElementsByTagName('OptimizerStatsUsage') #Make sure that only stats from the OptimizerStatsUsage section are gathered
    if($null -ne $OptimizerStatsUsage.StatisticsInfo)
    {
      $Elements = $OptimizerStatsUsage.GetElementsByTagName('StatisticsInfo')
      foreach ($Element in $Elements)
      {
        Write-StatisticsInfo $Element $CapturedPlans_id
      }
    }
    #==================================================================================================
    #Write WaitStats to $DtWaitStats.
    #==================================================================================================
    $Elements = $Plan.GetElementsByTagName('TraceFlag')
    foreach ($Element in $Elements)
    {
      [void]$DtTraceFlag.Rows.Add($null, $CapturedPlans_id, $Element.Value, $Element.Scope)
    }
    #==================================================================================================
    #Write WaitStats to $DtWaitStats.
    #==================================================================================================
    $Elements = $Plan.GetElementsByTagName('WaitStats')
    if($Elements.Count -gt 0)
    {
      Write-WaitStats $Elements $CapturedPlans_id
    }
    #==================================================================================================
    #Write QueryTimeStats to $DtQueryTimeStats.
    #==================================================================================================
    $Elements = $Plan.GetElementsByTagName('QueryTimeStats')
    foreach ($Element in $Elements)
    {
      Write-QueryTimeStats $Element $CapturedPlans_id
    }
    #==================================================================================================
    #Write Query plan info to $DtRelop.
    #==================================================================================================
    $Elements = $Plan.GetElementsByTagName('RelOp') 
    foreach ($Element in $Elements)
    {
      Write-Relop $Element $CapturedPlans_id $Relop_id
      #==================================================================================================
      #Write Thread info to $DtRunTimeCountersPerThread.
      #==================================================================================================                              
      if ($null -ne $Element.RunTimeInformation)
      {
        Write-RuntimeInformation $Element $Relop_id 
      }
      $Relop_id++
    }
    #For nested loop joins, the value for 'Estimated Number Of Rows For AllExecutions' isn't in the execution plan
    #to obtain this number of rows read (Estimated Number Of Rows For AllExecutions) should be multiplied by the estimated
    $Elements = $Plan.GetElementsByTagName('NestedLoops')
    if($null -ne $Elements)
    {
      Write-NestedLoopInfo $Elements $CapturedPlans_id
    }
    #==================================================================================================
    #Write info from Intermediate table DtIntermidiateRelop to $DtRelop and clear $DtIntermidiateRelop.
    #==================================================================================================   
    <#Data is initially written to an 'Intermediate table'. When writing the nested loop info, data must be updated. 
      When searching in a large datatable, this really slows down the process and then it makes sense to use an intermidate table. #>
    foreach ($Row in $DtIntermidiateRelop)
    {
      [void]$DtRelop.ImportRow($Row)
    }
    $DtIntermidiateRelop.Clear()
    #==================================================================================================
    #Write ParamterList to $DtParameterList.
    #==================================================================================================   
    $Elements =  $Plan.GetElementsByTagName('ParameterList') | Where-object {$PsItem.ColumnReference -ne $null} | Select-Object -ExpandProperty ColumnReference
    if($null -ne $Elements)
    {
      Write-ParameterList $Elements $CapturedPlans_id
    }
  }
  catch
  {
    $Error[0] | Format-List -force
    throw
  }
}
Write-Output ("End of plan processing start bulk copy " + (Get-Date)) 
#==================================================================================================
#Write query info to [dbo].[StmtSimple]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'StmtSimple' -DataTable $DtStmtSimple
#==================================================================================================
#Write query info to [dbo].[StatementSetOptions]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'StatementSetOptions' -DataTable $DtStatementSetOptions
#==================================================================================================
#Write query info to [dbo].[QueryPlan]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'QueryPlan' -DataTable $DtQueryPlan
#==================================================================================================
#Write warning info to [dbo].[MissingIndex]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'MissingIndex' -DataTable $DtMissingIndex
#==================================================================================================
#Write warning info to [dbo].[Warnings]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'Warnings' -DataTable $DtPlanWarnings
#==================================================================================================
#Write query info to [dbo].[MemoryGrantInfo]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'MemoryGrantInfo' -DataTable $DtMemoryGrantInfo
#==================================================================================================
#Write query info to [dbo].[OptimizerHardwareDependentProperties]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'OptimizerHardwareDependentProperties' -DataTable $DtOptimizerHardwareDependentProperties
#==================================================================================================
#Write query info to [dbo].[StatisticsInfo]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'StatisticsInfo' -DataTable $DtStatisticsInfo
#==================================================================================================
#Write Waitstats info to [dbo].[TraceFlag]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'TraceFlag' -DataTable $DtTraceFlag
#==================================================================================================
#Write Waitstats info to [dbo].[WaitStats]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'WaitStats' -DataTable $DtWaitStats
#==================================================================================================
#Write query info to [dbo].[QueryTimeStats]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'QueryTimeStats' -DataTable $DtQueryTimeStats
#==================================================================================================
#Write node info to [dbo].[Relop]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'Relop' -DataTable $DtRelop
#==================================================================================================
#Write Thread info to [dbo].[RunTimeCountersPerThread]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'RunTimeCountersPerThread' -DataTable $DtRunTimeCountersPerThread
#==================================================================================================
#Write ParameterList info to [dbo].[ParameterList]
#==================================================================================================
Write-DataTableToDatabase -DbName $DbName -ServerName $ServerName -Schema 'dbo' -TableOutput 'ParameterList' -DataTable $DtParameterList
#==================================================================================================
#End of general script
#==================================================================================================
$EndTime = Get-Date
New-TimeSpan -Start $StartTime -End $EndTime | Select-Object -Property totalminutes, totalSeconds | Format-List