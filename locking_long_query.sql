1. -- Blocked sessions
SELECT NVL(s.username, '(oracle)') AS username,
s.osuser,
s.INST_ID,
s.sid,
s.serial#,
p.spid,
s.BLOCKING_SESSION,
s.BLOCKING_SESSION_STATUS,
s.lockwait,
s.status,
s.machine,
s.program,
TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time,
s.last_call_et AS last_call_et_secs,
s.module,
s.action,
s.client_info,
s.client_identifier,
a.sql_text,
a.sql_id
FROM gv$session s,
gv$process p,
gv$sqltext a
WHERE s.paddr = p.addr
--AND s.status = 'ACTIVE'
AND a.address = s.sql_address
AND a.hash_value = s.sql_hash_value
AND a.piece = 0
AND s.username IS NOT NULL
and (blocking_session_status = 'VALID'
OR sid IN (SELECT blocking_session
FROM gv$session
WHERE blocking_session_status = 'VALID') )
ORDER BY s.username, s.osuser;


2. active sessions
SELECT NVL(s.username, '(oracle)') AS username,
s.osuser,
s.INST_ID,
s.sid,
s.serial#,
p.spid,
s.lockwait,
s.status,
s.machine,
s.program,
TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time,
s.last_call_et AS last_call_et_secs,
s.module,
s.action,
s.client_info,
s.client_identifier,
a.sql_text,
a.sql_id
FROM gv$session s,
gv$process p,
gv$sqltext a
WHERE s.paddr = p.addr
AND s.status = 'ACTIVE'
AND a.address = s.sql_address
AND a.hash_value = s.sql_hash_value
AND a.piece = 0
and s.username is not null
ORDER BY s.last_call_et desc, s.username, s.osuser;


3. AWR Waits last 5hrs
select for_period, wait_class, event_name, number_of_waits, time_waited_sec
from
(select to_char(min(snap.BEGIN_INTERVAL_TIME),'DD-Mon-YY HH24:MI') ||' - ' || to_char(max(snap.END_INTERVAL_TIME),'DD-Mon-YY HH24:MI') for_period,
dhse.wait_class,
dhse.event_name,
round(sum(dhse.total_waits)) AS number_of_waits,
round(sum(dhse.time_waited_micro) / 1000000) AS time_waited_sec
-- ,snap.instance_number -- uncomment if you want by instance (RAC)
FROM DBA_HIST_SYSTEM_EVENT dhse,
DBA_HIST_SNAPSHOT snap
WHERE
dhse.snap_id = snap.snap_id
and snap.END_INTERVAL_TIME > SYSDATE - 5/24 -- 5 hours
and dhse.wait_class !='Idle'
and dhse.event_name not like 'SQL*N%'
group by dhse.wait_class,dhse.event_name
--, snap.instance_number -- uncomment if you want by instance (RAC)
--having round(sum(dhse.time_waited_micro) / 1000000) > 180 --3minutes total waits
order by 5 desc )
where rownum <= 10 ;


4. long operations
SELECT s.inst_id,
s.sid,
s.serial#,
s.username,
sl.message,
to_char(sl.START_TIME,'dd/mm/yyyy HH24:MI:SS') started ,
ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
ROUND(decode(sl.sofar,0,1,sl.sofar)/decode(sl.totalwork,0,1,sl.totalwork)*100) progress_pct
FROM gv$session s,
gv$session_longops sl
WHERE s.sid = sl.sid
AND s.inst_id = sl.inst_id
AND s.serial# = sl.serial#
order by s.serial#,sl.START_TIME;