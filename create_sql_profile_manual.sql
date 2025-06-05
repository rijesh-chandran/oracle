SQL> create table prof_hint (hint varchar2(4000));

Table created.

SQL> create table prof_details (prof_name varchar2(80),sql_fulltext clob);

Table created.

SQL> insert into prof_details select 'MySQLProfile_Name',sql_fulltext from v$sql where sql_id='7vh1h0mssd0up' and child_number=0;

1 row created.

SQL>
SQL> insert into prof_hint
  2  select (extractvalue(value(d), '/hint')) as outline_hints
  3  from
  4  xmltable('/*/outline_data/hint'
  5  passing (
  6  select
  7  xmltype(other_xml) as xmlval
  8  from
  9  v$sql_plan
 10  where
 11  sql_id = '7vh1h0mssd0up'
 12  and child_number = 0
 13  and other_xml is not null)) d;

10 rows created.

SQL> 

SQL> declare
  2    profile_hints sys.sqlprof_attr;
  3    sql_text clob;
  4    profile_name varchar2(80);
  5  begin
  6    select hint bulk collect into profile_hints from prof_hint;
  7    select sql_fulltext, prof_name into sql_text,profile_name from prof_details;
  8    dbms_sqltune.import_sql_profile(
  9  	sql_text => sql_text,
 10  	profile => profile_hints,
 11  	category => 'DEFAULT',
 12  	name => profile_name,
 13  	force_match => TRUE
 14  	-- replace => true
 15    );
 16  end;
 17  /

PL/SQL procedure successfully completed.

SQL>