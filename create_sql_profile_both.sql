-- Create SQL Profile from v$sql and v$sql_plan

declare
ar_profile_hints sys.sqlprof_attr;
cl_sql_text clob;
begin
select sql_fulltext into cl_sql_text from v$sql where sql_id = 'fx91dju5vz2qw' and child_number = 1;
select extractvalue(value(d), '/hint') as outline_hints
bulk collect into ar_profile_hints
from xmltable('/*/outline_data/hint'
passing (
select
xmltype(other_xml) as xmlval
from v$sql_plan where sql_id = 'fx91dju5vz2qw' and child_number = 1 and plan_hash_value=4093811059 and other_xml is not null)
) d;
dbms_sqltune.import_sql_profile(
sql_text => cl_sql_text,
profile => ar_profile_hints,
category => 'DEFAULT',
name => 'PROF_fx91dju5vz2qw_4093811059',
force_match => TRUE
);
end;
/

-- Create SQL Profile from dba_hist_sqltext and dba_hist_sql_plan

declare 
ar_profile_hints sys.sqlprof_attr;
cl_sql_text clob;
begin
select sql_fulltext into cl_sql_text from dba_hist_sqltext where sql_id = 'fx91dju5vz2qw';
select extractvalue(value(d), '/hint') as outline_hints
bulk collect into ar_profile_hints
from xmltable('/*/outline_data/hint'
passing (
select
xmltype(other_xml) as xmlval
from dba_hist_sql_plan where sql_id = 'fx91dju5vz2qw' and plan_hash_value=4093811059 and other_xml is not null)
) d;
dbms_sqltune.import_sql_profile(
sql_text => cl_sql_text,
profile => ar_profile_hints,
category => 'DEFAULT',
name => 'PROF_fx91dju5vz2qw_4093811059',
force_match => TRUE
);
end;
/
