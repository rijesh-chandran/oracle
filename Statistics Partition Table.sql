CREATE TABLE PARTTABLE
    (    col1        DATE,
         col2        number,
         col3        number,
         constraint   pk_parttable primary key (col1,col2)
    )    
        PARTITION BY RANGE (col1)
        (PARTITION PARTTABLE_1995 VALUES LESS THAN (TO_DATE('01-JAN-1996','DD-MON-YYYY','NLS_DATE_LANGUAGE = American')),
         PARTITION PARTTABLE_1996 VALUES LESS THAN (TO_DATE('01-JAN-1997','DD-MON-YYYY','NLS_DATE_LANGUAGE = American')),
         PARTITION PARTTABLE_1997 VALUES LESS THAN (TO_DATE('01-JAN-1998','DD-MON-YYYY','NLS_DATE_LANGUAGE = American')),
         PARTITION PARTTABLE_1998 VALUES LESS THAN (TO_DATE('01-JAN-1999','DD-MON-YYYY','NLS_DATE_LANGUAGE = American')),
         PARTITION PARTTABLE_1999 VALUES LESS THAN (TO_DATE('01-JAN-2000','DD-MON-YYYY','NLS_DATE_LANGUAGE = American'))
        );

-- set incremental for the table
begin
dbms_stats.set_table_prefs(user, 'PARTTABLE', 'ESTIMATE_PERCENT', DBMS_STATS.AUTO_SAMPLE_SIZE);
dbms_stats.set_table_prefs(user, 'PARTTABLE', 'INCREMENTAL', 'TRUE');
dbms_stats.set_table_prefs(user, 'PARTTABLE', 'PUBLISH', 'TRUE');
dbms_stats.set_table_prefs(user, 'PARTTABLE', 'GRANULARITY', 'AUTO');
end;
/

insert into PARTTABLE select * from (select TO_DATE('01-JAN-1996','DD-MON-YYYY')+rownum, rownum,rownum*2 from dba_objects where rownum<101);

insert into PARTTABLE select * from (select TO_DATE('01-JAN-1995','DD-MON-YYYY')+rownum, rownum/3,rownum*3 from dba_objects where rownum<101);

insert into PARTTABLE select * from (select TO_DATE('01-JAN-1997','DD-MON-YYYY')+rownum, rownum/3,rownum*3 from dba_objects where rownum<101);

insert into PARTTABLE select * from (select TO_DATE('01-JAN-1999','DD-MON-YYYY')+rownum, rownum*rownum,rownum*3 from dba_objects where rownum<101);
commit;


exec DBMS_AUTO_TASK_IMMEDIATE.GATHER_OPTIMIZER_STATS;

select * from dba_autotask_client_job;
select * from dba_optstat_operations where operation like '%auto%' order by start_time;
select * from dba_optstat_operation_tasks where opid=662 and target not like '%"SYS".%';
select 
	owner
,	table_name
,	partition_name
,	object_type
,	num_rows
,	blocks
,	last_analyzed
,	global_stats
,	user_stats
,	stattype_locked
,	stale_stats 
from 
	dba_tab_statistics 
where 
	owner='PPSUSER' 
and 
	table_name='PARTTABLE';
select * from dba_tab_partitions where table_owner='PPSUSER';
select * from dba_tab_modifications where table_owner='PPSUSER';

alter session set nls_date_format='DD-MM-YY HH24:MI:SS';

select partition_name,sample_size,num_rows,  LAST_ANALYZED
from dba_tab_partitions
where table_owner='PPSUSER'
and table_name='PARTTABLE'
order by partition_name;

select table_name,sample_size,num_rows,  LAST_ANALYZED
from dba_tables
where owner='PPSUSER'
and table_name='PARTTABLE';

select COLUMN_NAME, NUM_DISTINCT, DENSITY, NUM_NULLS,  LAST_ANALYZED, SAMPLE_SIZE, AVG_COL_LEN
from dba_tab_columns
where owner='PPSUSER'
and table_name='PARTTABLE'
order by column_id;
  
insert into PARTTABLE select * from (select TO_DATE('01-JAN-1996','DD-MON-YYYY')+rownum, rownum+151,rownum*2 from dba_objects where rownum<10);
insert into PARTTABLE select * from (select TO_DATE('01-JAN-1998','DD-MON-YYYY')+rownum, rownum/3,rownum*3 from dba_objects where rownum<40);
insert into PARTTABLE select * from (select TO_DATE('01-JAN-1996','DD-MON-YYYY')+rownum, rownum+101,rownum*2 from dba_objects where rownum<2);
