EXEC master.dbo.sp_WhoIsActive 
				  @help=1

--kill 67

EXEC master.dbo.sp_WhoIsActive
  @show_own_spid = 1,
  @get_avg_time = 1,
  @get_plans = 1,
  @get_outer_command = 1,
  @get_full_inner_text = 1,
  @get_locks = 1,
  @find_block_leaders = 1,
  @get_task_info = 2,
  @get_additional_info = 1,
  @sort_order = '[session_id] DESC'

  EXEC master.dbo.sp_WhoIsActive
  @show_own_spid = 1,
  @get_avg_time = 1,
  @get_plans = 1,
  @get_outer_command = 1,
  @get_full_inner_text = 1,
  @get_locks = 1,
  @find_block_leaders = 1,
  @get_task_info = 2,
  @get_additional_info = 1,
  @sort_order = '[CPU] DESC'

  --AU_MusteriHizmetleri
  EXEC master.dbo.sp_WhoIsActive
  @show_own_spid = 1,
  @get_avg_time = 1,
  @get_plans = 1,
  @get_outer_command = 1,
  @get_full_inner_text = 1,
  @get_locks = 1,
  @find_block_leaders = 1,
  @get_task_info = 2,
  @get_additional_info = 1,
  @filter_type = 'login',
  @filter = 'AU_Hoy'
 

EXEC sp_WhoIsActive 
  @delta_interval = 10,
  @show_own_spid = 1,
  @get_avg_time = 1,
  @get_plans = 1,
  @get_outer_command = 1,
  @get_full_inner_text = 1,
  @get_transaction_info = 1,
  @get_locks = 1,
  @find_block_leaders = 1,
  @get_task_info = 2,
  @get_additional_info = 1

EXEC sp_WhoIsActive 
    @show_sleeping_spids = 2, 
    @show_system_spids = 1, 
    @show_own_spid = 1

--0:There is an open transaction
--1:the only sleeping sessions
--2:all sleeping sessions
EXEC sp_WhoIsActive 
    @show_sleeping_spids = 0

--1:background and system processes.
EXEC sp_WhoIsActive 
    @show_system_spids = 1

EXEC sp_WhoIsActive  
    @show_own_spid = 1

exec dbo.sp_WhoIsActive @get_task_info = 2 
--@get_transaction_info=1
exec dbo.sp_WhoIsActive @get_transaction_info=1 


--@get_plans
exec dbo.sp_WhoIsActive @get_plans=1, @get_additional_info=1
--specificy sort order =1
EXEC dbo.sp_WhoIsActive @sort_order = '[CPU] DESC'
--change output order of columns and include the query plan
EXEC dbo.sp_WhoIsActive 
	@get_plans = 1,
	@output_column_list = '[dd%],[session_id],[CPU],[physical_reads],
		[used_memory],[database_name],[login_name],[sql_text],[query_plan]';

--@filter_type='session', 'program', 'database', 'login' and 'host'
exec dbo.sp_WhoIsActive @filter_type = 'database', @filter = 'AkilliGise'
exec dbo.sp_WhoIsActive @filter_type = 'login', @filter = 'AU_MusteriHizmetleri'

--@get_transaction_info = 1
exec dbo.sp_WhoIsActive @get_transaction_info = 1
--@get_locks = 1
exec dbo.sp_WhoIsActive @get_locks = 1
--@output_column_list = '[dd%][session_id][sql_text][sql_command][login_name][wait_info][tasks][tran_log%][cpu%][temp%][block%][reads%][writes%][context%][physical%][query_plan][locks][%]' 
exec dbo.sp_WhoIsActive @output_column_list = '[dd%][session_id][sql_text][sql_command][login_name][wait_info][tasks][tran_log%][cpu%][temp%][block%][reads%][writes%][context%][physical%][query_plan][locks][%]' 


EXEC dbo.sp_who3
EXEC dbo.sp_who3n
EXEC.dbo.sp_who2
EXEC dbo.sp_who
