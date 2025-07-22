alter session set nls_timestamp_tz_format ='DD/MM/YYYY HH24:MI:SS TZR TZD';
alter session set nls_date_format ='DD-MM-YYYY HH24:MI:SS';
set pagesize 9999
spool /tmp/dba_autotask_client.html
set markup html on
select * from DBA_AUTOTASK_CLIENT;
select * from DBA_AUTOTASK_CLIENT_HISTORY;
select * from DBA_AUTOTASK_CLIENT_JOB;
select * from DBA_AUTOTASK_JOB_HISTORY order by JOB_START_TIME;
select * from DBA_AUTOTASK_OPERATION;
select * from DBA_AUTOTASK_SCHEDULE order by START_TIME;
select * from DBA_AUTOTASK_TASK;
select * from DBA_AUTOTASK_WINDOW_CLIENTS;
select * from DBA_AUTOTASK_WINDOW_HISTORY order by WINDOW_START_TIME;
select * from dba_scheduler_windows;
select * from dba_scheduler_window_groups;
select * from dba_scheduler_job_run_details order by ACTUAL_START_DATE;
select * from DBA_SCHEDULER_JOB_LOG;
SELECT program_name, program_action, enabled FROM dba_scheduler_programs;
set markup html off
spool off



BEGIN
      DBMS_AUTO_TASK_ADMIN.DISABLE(
        client_name => 'sql tuning advisor',
        operation => 'automatic sql tuning task',
        window_name => NULL
      );
END;
/


BEGIN
      DBMS_AUTO_TASK_ADMIN.ENABLE(
        client_name => 'auto space advisor',
        operation => 'auto space advisor job',
        window_name => NULL
      );
END;
/


SQL> select CLIENT_NAME,OPERATION_NAME,STATUS from dba_autotask_operation;
 
CLIENT_NAME                         OPERATION_NAME                STATUS
----------------------------------- ----------------------------- ----------
auto optimizer stats collection     auto optimizer stats job      DISABLED
auto space advisor                  auto space advisor job        DISABLED
sql tuning advisor                  automatic sql tuning task     DISABLED
 
SQL>

BEGIN
      DBMS_AUTO_TASK_ADMIN.ENABLE(
        client_name => 'sql tuning advisor',
        operation => 'automatic sql tuning task',
        window_name => NULL
      );
	  COMMIT;
END;
/
