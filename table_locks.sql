-- view table locks

col oracle_username form a15
col os_user_name form a15
col "OBJECT OWNER" form a15
col object_name form a30
col object_type form a20

select a.session_id,a.oracle_username, a.os_user_name, b.owner "OBJECT OWNER", b.object_name,b.object_type,a.locked_mode from 
(select object_id, SESSION_ID, ORACLE_USERNAME, OS_USER_NAME, LOCKED_MODE from gv$locked_object) a, 
(select object_id, owner, object_name,object_type from dba_objects) b
where a.object_id=b.object_id;
