variable x number
BEGIN
:x := dbms_spm.load_plans_from_awr(
begin_snap => 292,
end_snap => 294,
basic_filter => q'# sql_id='3wwhfmb2ztb40' and plan_hash_value='3080277828' #');
END;
/
print x



Using SQL Tuning Set (Prior to 19c):

BEGIN
  DBMS_SQLTUNE.CREATE_SQLSET(
    sqlset_name => 'MY_STS_03JUL25',
    description => 'SQL Tuning Set for loading plan into SQL Plan Baseline');
END;
/

DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(P)
    FROM TABLE(
       dbms_sqltune.select_workload_repository(begin_snap=>84139, end_snap=>84140,basic_filter=>'sql_id = ''f9948h4y2aa22''',attribute_list=>'ALL')
              ) p;
     DBMS_SQLTUNE.LOAD_SQLSET( sqlset_name=> 'MY_STS_03JUL25', populate_cursor=>cur);
  CLOSE cur;
END;
/

SELECT
  first_load_time          ,
  executions as execs              ,
  parsing_schema_name      ,
  elapsed_time  / 1000000 as elapsed_time_secs  ,
  cpu_time / 1000000 as cpu_time_secs           ,
  buffer_gets              ,
  disk_reads               ,
  direct_writes            ,
  rows_processed           ,
  fetches                  ,
  optimizer_cost           ,
  sql_plan                ,
  plan_hash_value          ,
  sql_id                   ,
  sql_text
FROM TABLE(DBMS_SQLTUNE.SELECT_SQLSET(sqlset_name => 'MY_STS_03JUL25'));
			 

DECLARE
my_plans pls_integer;
BEGIN
  my_plans := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(
    sqlset_name => 'MY_STS_03JUL25', 
    basic_filter=>'plan_hash_value = ''3166698470'''
    );
END;
/
