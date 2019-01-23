      set lines 200
        set pages 200
        col inst_id format 999
        col sid format 99999
        col serial# format 99999
        col machine format a10
        col progress_pct format 999999.00
        col elapsed format a8
        col remaining format a10
        col message format a100
        col Finish for a20
        break on sid on serial# on machine skip 0
        select s.inst_id,
               s.sid,
               s.serial#,
               s.machine,
               floor(sl.elapsed_seconds/3600)||':'||
                                 floor(mod(sl.elapsed_seconds,3600)/60)||':'||
                                 mod(mod(sl.elapsed_seconds,3600),60) elapsed,
                           /*floor(sl.time_remaining/3600)||':'||
                                 floor(mod(sl.time_remaining,3600)/60)||':'||
                                 mod(mod(sl.time_remaining,3600),60) remaining,*/
               to_char(sysdate + sl.time_remaining/86400, 'DD-MM-YYYY HH24:MI:SS') as Finish,
               round(sl.sofar/decode(sl.totalwork,0,1,sl.totalwork)*100, 2) progress_pct,
               sl.sql_id,
               message
          from gv$session s,
               gv$session_longops sl
        where s.inst_id = sl.inst_id
           and s.sid     = sl.sid
           and s.serial# = sl.serial#
           and round(sl.sofar/decode(sl.totalwork,0,1,sl.totalwork)*100, 2) <= 100
           and sl.sofar <> sl.totalwork
        order by sid, progress_pct
        /
	clear breaks