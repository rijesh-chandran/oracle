create or replace procedure trc_on 
as 
begin
execute immediate 'alter session set tracefile_identifier=''test''';
execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
end;
/

create or replace procedure trc_off
as 
begin
execute immediate 'alter session set events ''10046 trace name context off''';
end;
/

exec trc_on@dblink;
run query here 
exec trc_off@dblink
