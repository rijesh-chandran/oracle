select a.SID "Blocking Session", b.SID "Blocked Session"
from v$lock a, v$lock b
where a.SID != b.SID and a.ID1 = b.ID1 and a.ID2 = b.ID2 and
b.request > 0 and a.block = 1;


col blocking_status for a120;
select s1.username || '@' || s1.machine
|| ' ( SID=' || s1.sid || ' ) is blocking '
|| s2.username || '@' || s2.machine
|| ' ( SID=' || s2.sid || ' ) ' AS blocking_status
from v$lock l1, v$session s1, v$lock l2, v$session s2
where s1.sid=l1.sid and s2.sid=l2.sid
and l1.BLOCK=1 and l2.request > 0
and l1.id1 = l2.id1
and l2.id2 = l2.id2 ;


SELECT
blocking_session "BLOCKING_SESSION",
sid "BLOCKED_SESSION",
serial# "BLOCKED_SERIAL#",
seconds_in_wait/60 "WAIT_TIME(MINUTES)"
FROM v$session
WHERE blocking_session is not NULL
ORDER BY blocking_session;


SELECT SES.SID, SES.SERIAL# SER#, SES.PROCESS OS_ID, SES.STATUS, SQL.SQL_FULLTEXT
FROM V$SESSION SES, V$SQL SQL, V$PROCESS PRC
WHERE
SES.SQL_ID=SQL.SQL_ID AND
SES.SQL_HASH_VALUE=SQL.HASH_VALUE AND
SES.PADDR=PRC.ADDR AND
SES.SID=&Enter_blocked_session_SID;



set lines 200
set pagesize 66
break on Kill on sid on username on terminal
column Kill heading 'Kill String' format a13
column res heading 'Resource Type' format 999
column id1 format 9999990
column id2 format 9999990
column locking heading 'Lock Held/Lock Requested' format a40
column lmode heading 'Lock Held' format a20
column request heading 'Lock Requested' format a20
column serial# format 99999
column username format a10 heading "Username"
column terminal heading Term format a6
column tab format a30 heading "Table Name"
column owner format a9
column LAddr heading "ID1 - ID2" format a18
column Lockt heading "Lock Type" format a40
column command format a25
column sid format 990

SELECT
s.inst_id,
l.sid,
s.serial#,
nvl(
s.username, 'Internal'
) username,
s.event,
s.state,
decode(
s.command, 0, 'None', decode(
l.id2, 0, u1.name
|| '.'
|| substr(
t1.name, 1, 20
), 'None'
)
) tab,
c.command_name command,
decode(
l.lmode, 1, 'No Lock', 2, 'Row Share', 3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive', 6, 'Exclusive', '--none--'
) lmode,
decode(
l.request, 1, 'No Lock', 2, 'Row Share', 3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive', 6, 'Exclusive', '--none--'
) request,
l.id1
|| '-'
|| l.id2 laddr,
l.type
|| ' - '
|| lt.description lockt
FROM
gv$lock l,
gv$session s,
sys.user$ u1,
sys.obj$ t1,
v$sqlcommand c,
v$lock_type lt
WHERE
l.sid = s.sid
AND l.inst_id = s.inst_id
AND t1.obj# = decode(
l.id2, 0, l.id1, 1
)
AND u1.user# = t1.owner#
AND s.type != 'BACKGROUND'
AND c.command_type = s.command
AND lt.type = l.type
ORDER BY
s.inst_id,
s.sid
/