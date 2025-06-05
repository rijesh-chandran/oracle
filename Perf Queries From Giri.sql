1. High CPU Sessions

col username for a20

select nvl(ss.USERNAME,'ORACLE PROC') username,
ss.SID, ss.serial#,ss.sql_id,ss.sql_hash_value,sa.executions,VALUE cpu_usage from v$session ss,
v$sesstat se, v$sqlarea sa, v$statname sn where se.STATISTIC# = sn.STATISTIC#
and NAME like '%CPU used by this session%'
and se.SID = ss.SID
and ss.sql_hash_value = sa.hash_value
and value > 0
order by VALUE desc;

2. 

set lines 200
set pages 1000
col sid for 99999
col serial# for 99999
col spid for a5
col status for a8
col uname for a15
col program for a35
col module for a10
col action for a10
col event for a24
col LAST_ACTIVITY for a13
col LOGON_TIME for a12
col run_time for a9
col IDLE for a5
 
select sid, s.serial#,  p.spid, s.status, s.client_identifier UNAME, s.sql_id,s.sql_hash_value, to_char(s.logon_time, 'DD-MON HH24:SS') "LOGON_TIME", s.module, s.event, s.seconds_in_wait,ltrim(to_char(floor(s.LAST_CALL_ET/3600), '09')) || ':' || ltrim(to_char(floor(mod(s.LAST_CALL_ET, 3600)/60), '09')) || ':' || ltrim(to_char(mod(s.LAST_CALL_ET, 60), '09')) RUN_TIME, s.action from v$session s, v$process p, v$instance a where s.paddr = p.addr and (s.sid='&sid');

3. 

select  'AWR' source
        , plan_hash_value
        , sql_profile
        , sum(dsql.executions_delta) Execs
        ,sum(dsql.BUFFER_GETS_DELTA)/sum(decode(dsql.executions_delta,0,1,dsql.executions_delta)) bg2
        ,sum(dsql.DISK_READS_DELTA)/sum(decode(dsql.executions_delta,0,1,dsql.executions_delta)) dr2
        ,sum(dsql.ROWS_PROCESSED_DELTA)/sum(decode(dsql.executions_delta,0,1,dsql.executions_delta)) rp2
        ,sum(dsql.CPU_TIME_DELTA)/sum(decode(dsql.executions_delta,0,1,dsql.executions_delta))/1e6  cpu2
        ,sum(elapsed_time_total)/sum(decode(executions_total,0,1,executions_total))/1e6 elapsed
        ,avg(OPTIMIZER_COST)
from    dba_hist_sqlstat dsql
        , dba_hist_snapshot snaps
where sql_id='&sqlid'
        and  snaps.snap_id=dsql.snap_id
        and  snaps.dbid=dsql.dbid
        and snaps.dbid=(select dbid from v$database)
        and plan_hash_value > 0
group by plan_hash_value,sql_profile
union
select  'shared_pool' source
        , gvs.plan_hash_value
        , sql_profile
        , sum(gvs.executions)
        , sum(gvs.BUFFER_GETS)/sum(decode(gvs.executions,0,1,gvs.executions)) bg
        ,sum(gvs.DISK_READS)/sum(decode(gvs.executions,0,1,gvs.executions)) dr
        ,sum(gvs.ROWS_PROCESSED)/sum(decode(gvs.executions,0,1,gvs.executions)) rp
        ,sum(gvs.CPU_TIME)/sum(decode(gvs.executions,0,1,gvs.executions))/1e6  cpu
        ,sum(elapsed_time)/sum(decode(executions,0,1,executions))/1e6 elapsed
        ,avg(OPTIMIZER_COST)
from gv$sql gvs
where sql_id='&sqlid'
group by sql_id,plan_hash_value,sql_profile
order by 2;

4. 

select a.instance_number inst_id, a.sql_id,a.snap_id,a.plan_hash_value,  a.sql_profile,to_char(begin_interval_time,'dd-mon-yy hh24:mi') btime, abs(extract(minute from (end_interval_time-begin_interval_time)) + extract(hour from (end_interval_time-begin_interval_time))*60 + extract(day from (end_interval_time-begin_interval_time))*24*60) minutes,executions_delta executions, round(ELAPSED_TIME_delta/1000000/greatest(executions_delta,1),4) "avg duration (sec)" from dba_hist_SQLSTAT a, dba_hist_snapshot b
where sql_id='&sql_id' and a.snap_id=b.snap_id and a.instance_number=b.instance_number order by snap_id desc, a.instance_number;


5.

select sid, s.serial#,  p.spid, s.status, s.client_identifier UNAME, s.sql_id,s.sql_hash_value, to_char(s.logon_time, 'DD-MON HH24:SS') "LOGON_TIME", s.module, s.event, s.seconds_in_wait,ltrim(to_char(floor(s.LAST_CALL_ET/3600), '09')) || ':' || ltrim(to_char(floor(mod(s.LAST_CALL_ET, 3600)/60), '09')) || ':' || ltrim(to_char(mod(s.LAST_CALL_ET, 60), '09')) RUN_TIME, s.action from v$session s, v$process p, v$instance a where s.paddr = p.addr and s.sql_id in ( select sql_id from v$session where sql_id ='&sql_id');


6.

set lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 9,999,999,999.9
col avg_pio for 9,999,999,999.9
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(buffer_gets_delta/decode(nvl(executions_delta,0),0,1,executions_delta)) avg_lio,
(disk_reads_delta/decode(nvl(executions_delta,0),0,1,executions_delta)) avg_pio,
rows_processed_delta total_rows
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = '&sql_id'
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and s.instance_number = 1
order by 1, 2, 3
/