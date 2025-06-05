COL file_name FOR a80
SET lines 500 pages 900 feed ON
COL error FOR a30
COL tablespace_name FOR a20
SELECT hxfil file_num,SUBSTR(hxfnm,1,70) file_name,fhscn file_scn FROM x$kcvfh ORDER BY 1;
SELECT fuzzy, status, error, recover, checkpoint_change#, checkpoint_time, COUNT(*) 
from v$datafile_header GROUP BY fuzzy, status, error, recover, checkpoint_change#, checkpoint_time ;
select min(FHSCN) "LOW FILEHDR SCN", max(FHSCN) "MAX FILEHDR SCN", max(FHAFS) "Min PITR ABSSCN" from X$KCVFH ;
SELECT hxfil file#, SUBSTR(hxfnm, 1, 70) file_name, fhscn checkpoint_change#, fhafs Absolute_Fuzzy_SCN, MAX(fhafs) OVER () Min_PIT_SCN FROM x$kcvfh WHERE fhafs!=0 ORDER BY 1;
SELECT file#, SUBSTR(name, 1, 70) file_name, SUBSTR(tablespace_name, 1, 20) tablespace_name, undo_opt_current_change# FROM v$datafile_header WHERE fuzzy='YES' ORDER BY 1;
SELECT file#, SUBSTR(name, 1, 70) file_name, status, error, recover FROM v$datafile_header ORDER BY 1;
