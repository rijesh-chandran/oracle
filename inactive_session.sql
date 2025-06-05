set pagesize 40
col INST_ID for 99
col spid for a10
set linesize 150
col PROGRAM for a10
col action format a10
col logon_time format a16
col module format a13
col cli_process format a7
col cli_mach for a15
col status format a10
col username format a10
col last_call_et_Hrs for 9999.99
col sql_hash_value for 9999999999999
col username for a10
set linesize 152
set pagesize 80
col "Last SQL" for a60
col elapsed_time for 999999999999
select p.spid, s.sid,s.last_call_et/3600 last_call_et_Hrs ,s.status,s.action,s.module,s.program,t.disk_reads,lpad(t.sql_text,30) "Last SQL"
from gv$session s, gv$sqlarea t,gv$process p
where s.sql_address =t.address and
s.sql_hash_value =t.hash_value and
p.addr=s.paddr and
s.status='INACTIVE'
and s.last_call_et > (3600)
order by last_call_et;

select sql_id,sql_plan_baseline,sql_profile,last_active_time, first_load_time,last_load_time from v$sql where sql_plan_baseline is not null order by last_active_time desc;

select inst_id,sql_plan_baseline,count(*) from gv$sql where trunc(last_active_time)=trunc(sysdate) group by inst_id,sql_plan_baseline;

select inst_id,count(*) from gv$sql where sql_plan_baseline is not null and trunc(last_active_time)=trunc(sysdate) group by inst_id;