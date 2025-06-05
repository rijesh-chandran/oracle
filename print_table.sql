create or replace procedure print_table( p_query in varchar2 )
authid current_user
is
        l_theCursor     integer default dbms_sql.open_cursor;
        l_columnValue   varchar2(4000);
        l_status        integer;
        l_descTbl       dbms_sql.desc_tab;
        l_colCnt        number;
        l_rowcnt        number := 0;
begin
        execute immediate 'alter session set nls_date_format=''dd-mon-yyyy hh24:mi:ss'' ';
 
        dbms_sql.parse(  l_theCursor,  p_query, dbms_sql.native );
        dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );
 
        for i in 1 .. l_colCnt loop
                dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000 );
        end loop;
 
        l_status := dbms_sql.execute(l_theCursor);
 
        while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
                for i in 1 .. l_colCnt loop
                        dbms_sql.column_value( l_theCursor, i, l_columnValue );
                        dbms_output.put_line(
                                rpad( l_descTbl(i).col_name, 30 )
                                || ' : ' || l_columnValue
                        );
                end loop;
                dbms_output.new_line;
                dbms_output.put_line( '-----------------' );
                dbms_output.new_line;
                l_rowcnt := l_rowcnt + 1;
        end loop;
 
        dbms_output.put_line(l_rowcnt || ' rows selected');
 
        execute immediate 'alter session set nls_date_format=''dd-mon-rr'' ';
 
exception
        when others then
                execute immediate 'alter session set nls_date_format=''dd-mon-rr'' ';
        raise;
end;
/
 
-- create public synonym print_table for print_table;
-- grant execute on print_table to public;