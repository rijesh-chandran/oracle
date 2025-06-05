col compatibility for a10
col database_compatibility for a10
set lines 900 pages 900
col name for a20
col path for a40
select group_number GROUP#,name,allocation_unit_size au_size,state,type,round(total_mb/1024,2) total_gb,round(free_mb/1024,2) free_gb,compatibility,database_compatibility,voting_files
from v$asm_diskgroup order by group_number;
select group_number GROUP#,disk_number DISK#,name,header_status,mount_status,state,round(os_mb/1024,2) os_gb,round(total_mb/1024,2) total_gb,round(free_mb/1024,2) free_gb,path,substr(library,1,20) library,voting_file v  
from v$asm_disk order by group_number,disk_number;