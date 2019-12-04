SELECT
   [Session ID]         = s.session_id,
   [User Process]       = CONVERT(CHAR(1), s.is_user_process),
   [Login]              = s.login_name,  
   [Database]           = ISNULL(db_name(r.database_id), N''),
   [Task State]         = ISNULL(t.task_state, N''),
   [Blocked By]         = ISNULL(CONVERT (varchar, w.blocking_session_id), ''),
   [Command]            = ISNULL(r.command, N''),
   [Host Name]          = ISNULL(s.host_name, N''),
   [SQL]                = sqltext.text,
   --Elapsed Time (sec)]    = req.total_elapsed_time/1000,
        --CASE 
        --  WHEN req.total_elapsed_time/1000 < 1 THEN req.total_elapsed_time
        --  WHEN req.total_elapsed_time
   [Elapsed Time]        = IIF(req.total_elapsed_time/1000<60,cast(req.total_elapsed_time/1000 AS varchar) + ' sn', cast(req.total_elapsed_time/1000/60 as varchar)+' dk'),
   [Job Name]           = IIF(s.program_name LIKE '%job%',(SELECT sj.name from msdb..sysjobs sj 
                            INNER JOIN msdb..sysjobactivity sja ON sja.job_id = sj.job_id 
                                WHERE sj.enabled = 1 AND NOT sja.start_execution_date IS NULL
                                    AND sja.stop_execution_date IS NULL),''),
   [Application]        = ISNULL(s.program_name, N''),
   [Wait Type]          = ISNULL(w.wait_type, N''), 
   [Wait Time (ms)]      = ISNULL(w.wait_duration_ms, 0),
   [Wait Resource]      = ISNULL(w.resource_description, N''),
   [Head Blocker]       =
        CASE
            -- session has an active request, is blocked, but is blocking others
            WHEN r2.session_id IS NOT NULL AND r.blocking_session_id = 0 THEN '1'
            -- session is idle but has an open tran and is blocking others
            WHEN r.session_id IS NULL THEN '1'
            ELSE ''
        END, -- Selman AY
   [Total CPU (ms)] = s.cpu_time,
   [Total Physical I/O (MB)]   = (s.reads + s.writes) * 8 / 1024,
   [Memory Use (KB)]  = s.memory_usage * 8192 / 1024,
   [Open Transactions] = ISNULL(r.open_transaction_count,0),
   [Login Time]    = s.login_time,
   [Last Request Start Time] = s.last_request_start_time,
   [Net Address]   = ISNULL(c.client_net_address, N''),
   [Execution Context ID] = ISNULL(t.exec_context_id, 0),
   [Request ID] = ISNULL(r.request_id, 0),
   [Workload Group] = N''
FROM sys.dm_exec_sessions s
LEFT OUTER JOIN sys.dm_exec_connections c ON (s.session_id = c.session_id)
LEFT OUTER JOIN sys.dm_exec_requests r ON (s.session_id = r.session_id)
LEFT OUTER JOIN sys.dm_os_tasks t ON (r.session_id = t.session_id AND r.request_id = t.request_id)
LEFT OUTER JOIN sys.dm_exec_requests req ON (s.session_id = req.session_id)
--LEFT OUTER JOIN msdb..sysjobactivity sja ON sja.session_id = s.session_id
--LEFT JOIN msdb..sysjobs sj ON sj.job_id = sja.job_id
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS sqltext
LEFT OUTER JOIN
(
    -- In some cases (e.g. parallel queries, also waiting for a worker), one thread can be flagged as
    -- waiting for several different threads.  This will cause that thread to show up in multiple rows
    -- in our grid, which we don't want.  Use ROW_NUMBER to select the longest wait for each thread,
    -- and use it as representative of the other wait relationships this thread is involved in.
    SELECT *, ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
    FROM sys.dm_os_waiting_tasks
) w ON (t.task_address = w.waiting_task_address) AND w.row_num = 1
LEFT OUTER JOIN sys.dm_exec_requests r2 ON (r.session_id = r2.blocking_session_id)
where s.login_name <> 'sa' --and s.session_id = 110 
ORDER BY [Session ID];

 