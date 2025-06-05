set line 200 pages 999
col parametername for a40
col sessval for a30
col instval for a30
col defaultvalue a32
col is_session_modifiable for a20
col is_system_modifiable for a20
SELECT pi.ksppinm ParameterName, pcv.ksppstvl SessVal, psv.ksppstvl InstVal,pcv.KSPPSTDF "DefaultValue",
decode(bitand(pi.ksppiflg/256,1),1,'TRUE','FALSE') IS_SESSION_MODIFIABLE,
decode(bitand(pi.ksppiflg/65536,3),1,'IMMEDIATE',2,'DEFERRED',3,'IMMEDIATE','FALSE') IS_SYSTEM_MODIFIABLE
FROM x$ksppi pi, x$ksppcv pcv, x$ksppsv psv
WHERE pi.indx = pcv.indx AND pi.indx = psv.indx AND pi.ksppinm in ('open_cursors');