select snap_interval, retention from dba_hist_wr_control;
exec dbms_workload_repository.modify_snapshot_settings(retention => 57600) ;