set lines 999 pages 999
select inst_id,process,status,client_process,thread#,sequence#,block#,blocks from gv$managed_standby order by 1,2;


select thread#,max(sequence#) from v$archived_log where dest_id=1 group by thread#;
select thread#,max(sequence#) from v$archived_log where applied='YES' and dest_id=2 group by thread#;

set lines 999 pages 999
select thread#,max(sequence#) from v$archived_log where applied='YES' group by thread#;
select inst_id,process,status,client_process,thread#,sequence# from gv$managed_standby where process like '%MRP%';