SET pages 999 lines 999
SELECT * FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR(sql_id=>'&sql_id',cursor_child_no=> &child_number, format => 'ADVANCED'));
SELECT * FROM   TABLE(DBMS_XPLAN.DISPLAY_AWR(sql_id=>'&sql_id', plan_hash_value=> &plan_hash_value, db_id=>NULL, format => 'ADVANCED'));   
SELECT * FROM   TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(sql_handle=>'&sql_handle', plan_name=> '&plan_name', format => 'ADVANCED'));   

