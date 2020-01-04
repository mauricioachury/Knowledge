[select kstop.usr_id "User ID",
        uv.first_name || ',' || uv.last_name "User Name",
        to_char(kstop.start_time, 'dd/mm/yyyy') "Date",
        to_char(kstop.start_time, 'hh24:mi:ss') "IStop Time"
   from kvi_summary kstop
   join kvi_summary kstart
     on kstop.jobcodeid = 'ISTOP'
    and kstart.jobcodeid = 'ISTARTUP'
    and kstop.usr_id = kstart.usr_id
   join users_view uv
     on kstop.usr_id = uv.usr_id
  where kstop.start_time > kstart.stop_time
    and exists(select 'x'
                 from kvi_summary kasn
                where kasn.usr_id = kstop.usr_id
                  and kasn.start_time > kstart.start_time
                  and kasn.stop_time < kstop.start_time
                  and exists(select 'x'
                               from job_code_mapping jcm
                              where jcm.jobcodeintid = kasn.jobcodeintid))
    and not exists(select 'x'
                     from kvi_summary kend
                    where kend.usr_id = kstop.usr_id
                      and kend.start_time > kstart.start_time
                      and kend.start_time < kstop.start_time
                      and kend.jobcodeid = 'IEND')
    and not exists(select 'x'
                     from kvi_summary kss
                    where kss.usr_id = kstop.usr_id
                      and kss.jobcodeid = 'ISTARTUP'
                      and kss.start_time > kstart.start_time
                      and kss.start_time < kstop.start_time)
    and not exists (select 'x' 
                      from kvi_summary kst 
                     where kst.usr_id = kstop.usr_id 
                       and kst.jobcodeid in ('ISTARTUP', 'ISTOP') 
                       and kst.start_time > kstop.start_time)
  order by 1,
        4]