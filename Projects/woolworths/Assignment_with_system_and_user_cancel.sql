[select cmpdte,
        system_cancnt,
        user_cancnt,
        count(*) assignments
   from (select pv.list_id,
                to_char(pv.cmpdte, 'yyyy-mm-dd') cmpdte,
                sum(decode(cp.can_usr_id, 'SYSTEM', 1, 0)) system_cancnt,
                sum(decode(cp.can_usr_id, 'SYSTEM', 0, null, 0, 1)) user_cancnt
           from pcklst pv
           left
           join canpck cp
             on pv.list_id = cp.list_id
          where pv.list_sts = 'C'
            and pv.adddte > sysdate -7
          group by pv.list_id,
                to_char(pv.cmpdte, 'yyyy-mm-dd')) tmp
  group by system_cancnt,
        user_cancnt,
        cmpdte
  order by cmpdte desc,
        system_cancnt + user_cancnt desc];

[select cmpdte,
 totcan,
 sum(assignments) totasgn
from (select cmpdte,
         system_cancnt + user_cancnt totcan,
         count(*) assignments
    from (select pv.list_id,
                 to_char(pv.cmpdte, 'yyyy-mm-dd') cmpdte,
                 sum(decode(cp.can_usr_id, 'SYSTEM', 1, 0)) system_cancnt,
                 sum(decode(cp.can_usr_id, 'SYSTEM', 0, null, 0, 1)) user_cancnt
            from pcklst pv
            left
            join canpck cp
              on pv.list_id = cp.list_id
           where pv.list_sts = 'C'
             and pv.adddte > sysdate -7
             and pv.cmpdte is not null
           group by pv.list_id,
                 to_char(pv.cmpdte, 'yyyy-mm-dd')) tmp
   group by system_cancnt,
         user_cancnt,
         cmpdte
   order by cmpdte desc,
         system_cancnt + user_cancnt desc)
group by cmpdte,
 totcan
order by cmpdte desc]