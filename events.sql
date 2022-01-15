-- # Lalu Mostra os eventos das sess�es activas
     
column inst_id   format  9999999;
column sse       format a15
column username  format a15;
column osuser    format a15;
column logon_time format a20;
column LAST_CALL_ET format 99999999999999
column SECONDS_IN_WAIT format 99999999999999;
column program   format a30 ;

SELECT a.inst_id, ''''||a.sid||','||a.serial#||'''' sse
	, a.username
	, a.osuser
	, a.logon_time
        , a.LAST_CALL_ET
        , b.SECONDS_IN_WAIT
	, b.event
	, a.status
	, b.state
	, SUBSTR (a.program, 1, 30 ) program
	, a.terminal
	, a.MACHINE
	, a.SQL_ADDRESS
	, a.SQL_HASH_VALUE
	--, a.SQL_ID
	, b.p1
	, b.p1raw
	, b.p2 -- para decifrar o tipo de latch free: @v$latchname latch#
	, b.P2RAW
FROM 	  gV$SESSION a
	, gV$SESSION_WAIT b
	WHERE    a.inst_id=b.inst_id 
	and a.sid=b.sid
	AND a.username not in ('pmon','smon')
	AND a.status ='ACTIVE'
	--AND last_call_et > 600000
ORDER BY b.event, a.username, a.logon_time
/

-- Verificar se aparecem sess�es com 
-- Event                       
-- -----------------------
-- db file scattered read   est�o a fazer full tablescan