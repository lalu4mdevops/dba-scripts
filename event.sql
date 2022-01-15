###meda##
select inst_id, event , count(*) TOTAL
from gv$session_wait
group by inst_id, event 
order by inst_id, count(*) DESC;



