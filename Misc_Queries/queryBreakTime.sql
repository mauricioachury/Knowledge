publish data
 where start_dt = '2018-09-18 00:00'
   and end_dt = '2018-09-20 24:00'
|
if (@usr_id_in = '')
{
    [select distinct a.usr_id
       from kvi_adjustments k,
            jobcode j,
            kvi_summary a
      where k.jobcodeintid = j.jobcodeintid
        and k.kvisummaryintid = a.kvisummaryintid
        and j.jobcodeid in ('LUNCH', 'OVRTBREAK', 'BREAK')
        and to_char(k.adj_start_time, 'yyyy-mm-dd hh24:mi') >= @start_dt
        and to_char(k.adj_start_time, 'yyyy-mm-dd hh24:mi') <= @end_dt
        and a.status in ('C', 'A')] >> res
    |
    convert column results to string
     where colnam = 'usr_id'
       and res = @res
       and separator = ','
    |
    convert list to in clause
     where column_name = 'usr_id'
       and separator = ','
       and string = @result_string
    |
    publish data
     where usr_id_in = 't.' || @in_clause
}
|
[select distinct to_char(t.start_time, 'yyyy-mm-dd') break_date,
        t.usr_id pin_no,
        t.user_name,
        t.jobcodeid break_type,
        to_char(t.start_time, 'hh24:mi:ss') break_time,
        last_work_code,
        decode(dbt.devcod, null, nvl(b.tostol, b.frstol), b.frstol) last_location_before_break,
        to_char(b.trndte, 'hh24:mi:ss') last_work_time_before_break,
        floor((t.start_time - b.trndte) * 24 * 60) last_work_to_break_in_minute,
        decode(daf.devcod, null, nvl(a.frstol, a.tostol), a.tostol) first_location_after_break,
        to_char(a.trndte, 'hh24:mi:ss') first_work_time_after_break,
        floor((a.trndte - t.start_time) * 24 * 60) - decode(t.jobcodeid, 'LUNCH', 30, 12) break_to_first_work_in_minute
   from (select distinct a.usr_id,
                uv.last_name || ',' || uv.first_name as user_name,
                j.jobcodeid,
                a.jobcodeid last_work_code,
                k.adj_start_time as start_time
           from kvi_adjustments k,
                jobcode j,
                kvi_summary a,
                users_view uv
          where a.kvisummaryintid = k.kvisummaryintid
            and j.jobcodeintid = k.jobcodeintid
            and a.usr_id = uv.usr_id
            and a.status in ('C', 'A')
            and j.jobcodeid in ('LUNCH', 'OVRTBREAK', 'BREAK')) t
  left join dlytrn b
     on b.usr_id = t.usr_id
    and b.trndte < t.start_time
    and to_char(b.trndte, 'yyyy-mm-dd') = to_char(t.start_time, 'yyyy-mm-dd') 
    and b.dlytrn_id = (select max(tmp.dlytrn_id)
                         from dlytrn tmp
                        where tmp.usr_id = b.usr_id
                          and tmp.trndte < t.start_time)
   left
   join devmst dbt
     on b.tostol = dbt.devcod
    and b.wh_id = dbt.wh_id
  left join dlytrn a
     on b.usr_id = a.usr_id
    and a.trndte > t.start_time
    and to_char(a.trndte, 'yyyy-mm-dd') = to_char(t.start_time, 'yyyy-mm-dd') 
    and a.dlytrn_id = (select min(tmp.dlytrn_id)
                     from dlytrn tmp
                    where tmp.usr_id = a.usr_id
                      and tmp.trndte > t.start_time)
   left
   join devmst daf
     on a.frstol = daf.devcod
    and a.wh_id = daf.wh_id
  where @usr_id_in:raw
    and t.jobcodeid in ('LUNCH', 'OVRTBREAK', 'BREAK')
    and to_char(t.start_time, 'yyyy-mm-dd hh24:mi') >= @start_dt
    and to_char(t.start_time, 'yyyy-mm-dd hh24:mi') <= @end_dt
  order by pin_no,
        break_time]