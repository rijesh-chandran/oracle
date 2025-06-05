alter session set tracefile_identifier='SQL_TRACE';
alter session set timed_statistics=true;
alter session set events '10046 trace name context forever, level 12';
set timing on
<run the query here and wait for completion>
<after query was run perform below>
select * from dual;
alter session set events '10046 trace name context off';