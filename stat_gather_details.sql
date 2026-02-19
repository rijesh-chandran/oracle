col con_id head "Con|tai|ner" form 999
col id head "Opera|tion|ID" form 9999999
col operation head "Operation" form a30
col job_name head "job name" form a22
col target head "Target" form a10
col jst head "Operation|start|time" form a12
col duration head "Operation|dura|tion|mins" form 999999
col status head "Operation|status" form a10
select 	operation, job_name, target, to_char(start_time, 'DD-MON HH24:MI') jst,
extract(hour from (end_time - start_time))*60 + extract(minute from (end_time - start_time)) duration,
status
from  	dba_optstat_operations
where	operation = 'gather_database_stats (auto)'
order 	by  start_time
/


col con_id head "Con|tai|ner" form 999
col jst head "Operation|start|time" form a12
col target head "Target" form a60
col target_type head "Target Type" form a15
col status head "Operation|status" form a10
col duration head "Dura|tion|mins" form 999
select	to_char(start_time, 'DD-MON HH24:mi') jst,
target, target_type, status, 
extract(hour from (end_time - start_time))*60 + extract(minute from (end_time - start_time)) duration
from	dba_optstat_operation_tasks
where	opid=&opid
order	by start_time
/


col con_id head "Con|tai|ner" form 999
col window_name head "window" form a16
col wst head "window|start|time" form a12
col window_duration head "window|dura|tion|hours" form 999999
col job_name head "job name" form a22
col jst head "job|start|time" form a12
col job_duration head "job|dura|tion|mins" form 999999
col job_status head "job|status" form a10
col job_error head "job error" form 99
col job_info head "job info" form a40

select 	 window_name, to_char(window_start_time, 'DD-MON HH24:MI') wst,
	extract(hour from window_duration) + round(extract(minute from window_duration)/60) window_duration,
	job_name, to_char(job_start_time, 'DD-MON HH24:MI') jst, job_status,
	extract(hour from job_duration)*60 + round(extract(minute from job_duration)) job_duration,
	job_error, job_info
from 	dba_autotask_job_history
where 	client_name = 'auto optimizer stats collection'
order	by job_start_time
/