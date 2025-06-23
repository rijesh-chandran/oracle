variable x number
BEGIN
:x := dbms_spm.load_plans_from_awr(
begin_snap => 292,
end_snap => 294,
basic_filter => q'# sql_id='3wwhfmb2ztb40' and plan_hash_value='3080277828' #');
END;
/
print x
