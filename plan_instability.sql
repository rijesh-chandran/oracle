alter system set "_sql_plan_directive_mgmt_control" = 0;
alter system set "_optimizer_dsdir_usage_control" = 0;


SET lines 500 pages 900
COL begin_interval_time FOR a30 tru
SELECT ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
round((elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000, 3) avg_etime,
round((cpu_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000, 3) avg_ctime,
round((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)), 3) avg_lio,
round((disk_reads_delta/decode(nvl(disk_reads_delta,0),0,1,executions_delta)), 3) avg_pio,
round((rows_processed_delta/decode(nvl(rows_processed_delta,0),0,1,executions_delta)), 3) avg_rows
FROM DBA_HIST_SQLSTAT S,
DBA_HIST_SNAPSHOT SS
WHERE sql_id = '&sql_id'
AND ss.snap_id = S.snap_id
AND ss.instance_number = S.instance_number
AND ss.begin_interval_time > trunc(sysdate) - 30
AND executions_delta > 0
ORDER BY 1, 2, 3
/

- Create the baseline based on the best execution plan:

set serveroutput on
declare
l_ret number;
begin
l_ret := dbms_spm.load_plans_from_awr(
begin_snap => <INITIAL SNAP>,
end_snap => <END SNAP>,
basic_filter => q'# sql_id='<SQL ID>' and plan_hash_value = <PLAN HASH VALUE>#',
fixed => 'YES'
);
dbms_output.put_line('l_ret: '||l_ret);
end;
/


Example:

set serveroutput on
declare
l_ret number;
begin
l_ret := dbms_spm.load_plans_from_awr(
begin_snap => 159316,
end_snap => 159320,
basic_filter => q'# sql_id='4zc0cqkmum17s' and plan_hash_value = 3672220478#',
fixed => 'YES'
);
dbms_output.put_line('l_ret: '||l_ret);
end;
/

- Flush the existing cursors:

set serveroutput on
DECLARE
name varchar2(50);
version varchar2(3);
BEGIN
select regexp_replace(version,'\..*') into version from v$instance;

if version = '10' then
execute immediate
q'[alter session set events '5614566 trace name context forever']'; -- bug fix for 10.2.0.4 backport
end if;

select address||','||hash_value into name
from v$sqlarea
where sql_id like '5386yt7ajzvbw';

sys.dbms_shared_pool.purge(name,'C',1);

END;
/

SET serveroutput ON 
DECLARE
l_sql_tune_task_id VARCHAR2(100);
BEGIN
l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
sql_id => 'ahpp2wqmx515j',
scope => DBMS_SQLTUNE.scope_comprehensive,
time_limit => 3600,
task_name => 'ahpp2wqmx515j_tuning_task',
description => 'Tuning task for statement ahpp2wqmx515j.');
DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => 'ahpp2wqmx515j_tuning_task');

SET LONG 10000;
SET PAGESIZE 1000
SET LINESIZE 200
SELECT DBMS_SQLTUNE.report_tuning_task('ahpp2wqmx515j_tuning_task') AS recommendations FROM dual;



SELECT 
  sql_id,
  MAX(plan_hash_value) AS max_plan_hash_value,
  MIN(plan_hash_value) AS min_plan_hash_value,
  MAX(elapsed_time_delta) AS max_elapsed_time,
  MIN(elapsed_time_delta) AS min_elapsed_time,
  (MAX(elapsed_time_delta) - MIN(elapsed_time_delta)) AS elapsed_time_diff
FROM 
  dba_hist_sqlstat
WHERE 
  snap_id BETWEEN (SELECT MAX(snap_id) FROM dba_hist_snapshot WHERE end_interval_time >= SYSDATE - 5) - 10 AND (SELECT MAX(snap_id) FROM dba_hist_snapshot)
  AND sql_id IN (
    SELECT sql_id
    FROM dba_hist_sqlstat
    WHERE snap_id BETWEEN (SELECT MAX(snap_id) FROM dba_hist_snapshot WHERE end_interval_time >= SYSDATE - 5) - 10 AND (SELECT MAX(snap_id) FROM dba_hist_snapshot)
    GROUP BY sql_id
    HAVING COUNT(DISTINCT plan_hash_value) > 1
  )
GROUP BY 
  sql_id
ORDER BY
  elapsed_time_diff DESC
FETCH FIRST 10 ROWS ONLY;