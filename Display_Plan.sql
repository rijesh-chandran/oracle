SET pages 999 lines 999
SELECT * FROM   TABLE(DBMS_XPLAN.DISPLAY_CURSOR(sql_id=>'&sql_id',cursor_child_no=> &child_number, format => 'ADVANCED'));