--col logon_time format a25
--col spid format a10
--col sid format a10
--col serial# format a10
--col machine format a10
--col username format a10
--col osuser format a10
--col program format a30
--
--select
--b.logon_time logon_time,
--a.spid pid,
--b.sid sid,
--b.serial# serial#,
--b.machine box,
--b.username username,
--b.osuser os_user,
--b.program program
--from
--v$session b,
--v$process a
--where b.paddr = a.addr
--and b.sid=&SID;

select
substr(b.logon_time,1,25) logon_time,
substr(a.spid,1,10) pid,
substr(b.sid,1,8) sid,
substr(b.serial#,1,8) ser#,
substr(b.machine,1,6) box,
substr(b.username,1,10) username,
substr(b.osuser,1,8) os_user,
substr(b.program,1,30) program
from
gv$session b,
gv$process a
where b.paddr = a.addr
and b.sid in ('&SID');