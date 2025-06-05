SELECT sql_handle,plan_name,enabled,accepted FROM dba_sql_plan_baselines WHERE CREATED>(systimestamp-1/24);

variable x number
 
BEGIN
:x := dbms_spm.load_plans_from_awr(
begin_snap => 130610,
end_snap => 130610,
basic_filter => q'# sql_id='06xt6cm41dzrn' and plan_hash_value='1636521038' #',
enabled     => 'YES');
END;
/
 
variable x number

SET serveroutput ON 
DECLARE
x number; 
BEGIN
x:= DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (
   sql_id            => '06xt6cm41dzrn',
   plan_hash_value   => 1636521038,
   fixed             => 'NO',
   enabled           => 'NO')
DBMS_OUTPUT.PUT_LINE('Plans: '|| x);
END;
/
 
print :x


exec DBMS_SPM.CREATE_STGTAB_BASELINE('MIGBASELINE', 'MIGUSER','USERS');

SELECT sql_handle,plan_name,enabled,accepted FROM dba_sql_plan_baselines WHERE CREATED>(systimestamp-1/24);

set serveroutput on
DECLARE
x number;
BEGIN
x := DBMS_SPM.PACK_STGTAB_BASELINE(table_name=>'MIGBASELINE', table_owner=>'MIGUSER',sql_handle=>'SQL_HANDLE');
dbms_output.put_line(to_char(x) || ' plan baselines packed');
END;
/


-- On Target

set serveroutput on
DECLARE
x number;
BEGIN
x := DBMS_SPM.UNPACK_STGTAB_BASELINE(table_name=>'MIGBASELINE', table_owner=>'MIGUSER');
dbms_output.put_line(to_char(x) || ' plan baselines unpacked');
END;
/

