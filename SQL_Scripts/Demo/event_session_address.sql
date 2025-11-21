/*
https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-xe-session-events-transact-sql?view=azuresqldb-current

The event_fire_count and event_fire_average_time columns
 are populated only when trace flag 9708 is enabled.

 session_name |	event_name                        |	event_fire_count |	event_fire_average_time |	event_fire_min_time |	event_fire_max_time
 ------------------------------------------------------------------------------------------------------------------------------------------
QueryPlanLWP  |	query_post_execution_plan_profile |	6332	           | 13                       |	2                   |	168
*/

DBCC TRACEON(9708, -1);
GO
DBCC TRACESTATUS (9708, -1);
GO
DBCC TRACEOFF(9708, -1);
GO
DBCC TRACESTATUS (9708, -1);
GO

SELECT 
	s.[name] AS session_name, 
	se.event_name,
	se.event_fire_count,
	se.event_fire_average_time, 
	se.event_fire_min_time, 
	se.event_fire_max_time
FROM sys.dm_xe_sessions AS s 
INNER JOIN sys.dm_xe_session_events AS se
	ON s.[address] = se.event_session_address
WHERE event_name = 'query_post_execution_plan_profile'