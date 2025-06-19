SET ECHO OFF
SET TERMOUT ON
SET SERVEROUTPUT ON
SET TIMING OFF
DECLARE
   v1  varchar2(100);
   v2  varchar2(100);
   v3  varchar2(100);
   v4  varchar2(100);
   v5  varchar2(100);
   v6  varchar2(100);
   v7  varchar2(100);
   v8  varchar2(100);
   v9  varchar2(100);
   v10 varchar2(100);
BEGIN
   dbms_output.put_line('Automatic Stats Gathering Job - Parameters');
   dbms_output.put_line('==========================================');
   v1 := dbms_stats.get_prefs('AUTOSTATS_TARGET');
   dbms_output.put_line(' AUTOSTATS_TARGET:  ' || v1);
   v2 := dbms_stats.get_prefs('CASCADE');
   dbms_output.put_line(' CASCADE:           ' || v2);
   v3 := dbms_stats.get_prefs('DEGREE');
   dbms_output.put_line(' DEGREE:            ' || v3);
   v4 := dbms_stats.get_prefs('ESTIMATE_PERCENT');
   dbms_output.put_line(' ESTIMATE_PERCENT:  ' || v4);
   v5 := dbms_stats.get_prefs('METHOD_OPT');
   dbms_output.put_line(' METHOD_OPT:        ' || v5);
   v6 := dbms_stats.get_prefs('NO_INVALIDATE');
   dbms_output.put_line(' NO_INVALIDATE:     ' || v6);
   v7 := dbms_stats.get_prefs('GRANULARITY');
   dbms_output.put_line(' GRANULARITY:       ' || v7);
   v8 := dbms_stats.get_prefs('PUBLISH');
   dbms_output.put_line(' PUBLISH:           ' || v8);
   v9 := dbms_stats.get_prefs('INCREMENTAL');
   dbms_output.put_line(' INCREMENTAL:       ' || v9);
   v10:= dbms_stats.get_prefs('STALE_PERCENT');
   dbms_output.put_line(' STALE_PERCENT:     ' || v10);
END;
/

select dbms_stats.get_prefs('INCREMENTAL','PPSUSER','INVOICES') from dual;
