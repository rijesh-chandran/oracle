DECLARE
  TYPE num_type IS TABLE OF NUMBER(20);
  l_tab    num_type; 
  v_dbid number:=2107041760;
  v_counter number:=1000;
  CURSOR c_data IS
        SELECT
        snap_id
        FROM dba_hist_snapshot WHERE dbid=v_dbid AND TRUNC(begin_interval_time)<TRUNC(systimestamp-8) ORDER BY 1;
BEGIN
  OPEN c_data;
  LOOP
    FETCH c_data
    BULK COLLECT INTO l_tab LIMIT v_counter; 
    dbms_workload_repository.drop_snapshot_range(l_tab(l_tab.first),l_tab(l_tab.last),v_dbid);
	COMMIT;
    EXIT WHEN c_data%NOTFOUND;
  END LOOP
  CLOSE c_data;
END;
/
