GRANT EXECUTE ON SYS.DBMS_CRYPTO TO <username>;
CREATE OR REPLACE FUNCTION compute_sql_id (sql_text IN CLOB)
RETURN VARCHAR2 IS
 BASE_32 CONSTANT VARCHAR2(32) := '0123456789abcdfghjkmnpqrstuvwxyz';
 l_raw_128 RAW(128);
 l_hex_32 VARCHAR2(32);
 l_low_16 VARCHAR(16);
 l_q3 VARCHAR2(8);
 l_q4 VARCHAR2(8);
 l_low_16_m VARCHAR(16);
 l_number NUMBER;
 l_idx INTEGER;
 l_sql_id VARCHAR2(13);
BEGIN
 l_raw_128 := 
 SYS.DBMS_CRYPTO.hash(TRIM(CHR(0) FROM sql_text)||CHR(0), SYS.DBMS_CRYPTO.hash_md5);
 l_hex_32 := RAWTOHEX(l_raw_128); 
 l_low_16 := SUBSTR(l_hex_32, 17, 16); 
 l_q3 := SUBSTR(l_low_16, 1, 8); 
 l_q4 := SUBSTR(l_low_16, 9, 8); 
 l_q3 := SUBSTR(l_q3, 7, 2)||SUBSTR(l_q3, 5, 2)||SUBSTR(l_q3, 3, 2)||SUBSTR(l_q3, 1, 2);
 l_q4 := SUBSTR(l_q4, 7, 2)||SUBSTR(l_q4, 5, 2)||SUBSTR(l_q4, 3, 2)||SUBSTR(l_q4, 1, 2);
 l_low_16_m := l_q3||l_q4;
 SELECT TO_NUMBER(l_low_16_m, 'xxxxxxxxxxxxxxxx') INTO l_number FROM DUAL;
 FOR i IN 1 .. 13
 LOOP
 l_idx := TRUNC(l_number / POWER(32, (13 - i))); 
 l_sql_id := l_sql_id||SUBSTR(BASE_32, (l_idx + 1), 1); 
 l_number := l_number - (l_idx * POWER(32, (13 - i))); 
 END LOOP;
 RETURN l_sql_id;
END compute_sql_id;
/
SHOW ERRORS;
-- test
SET SERVEROUT ON;
SELECT compute_sql_id('select ''Slavik'' from dual') FROM DUAL;