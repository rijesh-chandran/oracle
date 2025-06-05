select o.object_name, s.sid, s.serial#, p.spid, s.program, sq.sql_fulltext, s.logon_time
from
    v$locked_object l, dba_objects o, v$session s, v$process p, v$sql sq
where
    l.object_id = o.object_id and l.session_id = s.sid and s.paddr = p.addr and s.sql_address = sq.address 
	and object_name='PCX_TRANSACTIONALDATA_REDEF';