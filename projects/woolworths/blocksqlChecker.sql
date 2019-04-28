[select s1.username || '@' || s1.machine || '(SID=' || s1.sid || ') is blocking ' || s2.username || '@' || s2.machine || ' (SID=' || s2.sid || ')' blocking_status,
     q1.sql_id sql_id_src,
     q1.sql_text sql_text_src,
     'Is blocking' action,
     q2.sql_id sql_id_dst,
     q2.sql_text sql_text_dst
from gv$lock l1,
     gv$session s1,
     gv$sql q1,
     gv$lock l2,
     gv$session s2,
     gv$sql q2
where s1.sid = l1.sid
 and nvl(s1.sql_id, s1.prev_sql_id) = q1.sql_id
 and s2.sid = l2.sid
 and s2.sql_id = q2.sql_id
 and l1.block = 1
 and l2.request > 0
 and l1.id1 = l2.id1
 and l1.id2 = l2.id2]