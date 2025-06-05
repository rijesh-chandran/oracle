-- Find the session trace file with SID:
SELECT p.tracefile FROM v$session s JOIN v$process p ON s.paddr = p.addr WHERE  s.sid = 3486;

-- Find the alert.log location:
SELECT value FROM v$diag_info WHERE name='Diag Trace'; 