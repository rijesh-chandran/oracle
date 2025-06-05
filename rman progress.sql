SELECT sid, serial#, context, sofar, totalwork,ROUND ((sofar/totalwork)*100, 2) "% COMPLETE"
FROM v$session_longops WHERE opname LIKE 'RMAN%' AND opname NOT LIKE '%aggregate%' AND totalwork! = 0 AND sofar <> totalwork; 

COL status FORMAT a9
COL hrs FORMAT 999.99
SELECT session_key, input_type, status,TO_CHAR(start_time,'mm/dd/yy hh24:mi') start_time,TO_CHAR(END_TIME,'mm/dd/yy hh24:mi') end_time, elapsed_seconds/3600 hrs
FROM v$rman_backup_job_details ORDER BY session_key;