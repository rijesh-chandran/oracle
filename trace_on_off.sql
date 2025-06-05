create or replace procedure trc_on 
as
begin
execute immediate 'alter session set tracefile_identifier=''SQL_TRACE''';
execute immediate 'alter session set timed_statistics=true';
execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
end;
/

create or replace procedure trc_off 
as
begin
execute immediate 'alter session set events ''10046 trace name context off''';
end;
/


execute trc_on;
execute trc_on@DBLINK;
SELECT * FROM SUPPORT_DW.MDM_ACTIVITE@PARADMP1_S.WORLD WHERE ROWNUM = 1;
execute trc_off@DBLINK;
execute trc_off


