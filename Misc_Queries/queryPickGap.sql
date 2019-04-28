publish data
 where start_dt = '2018-10-19 09:00'
   and end_dt = '2018-10-19 20:00'
   and usr_id_in = "b.usr_id in ('3154')"
|
[select 
        b.usr_id pin_no,
        uv.last_name || ',' || uv.first_name as user_name,
        to_char(b.trndte, 'yyyy-mm-dd') break_date,
        decode(dbt.devcod, null, nvl(b.tostol, b.frstol), b.frstol) last_pick_location,
        to_char(b.trndte, 'hh24:mi:ss') last_pick_time,
        0 uoms_picked,
        t.jobcodeid break_type,
        to_char(t.start_time, 'hh24:mi:ss') break_start_time,
        decode(daf.devcod, null, nvl(a.frstol, a.tostol), a.tostol) next_pick_location,
        to_char(a.trndte, 'hh24:mi:ss') next_pick_location_time,
        floor((a.trndte - b.trndte) * 24 * 60) time_in_between_locations,
        b.lodnum LPN
   from dlytrn b
   join devmst dbt
     on b.tostol = dbt.devcod
    and b.wh_id = dbt.wh_id
   join dlytrn a
     on b.usr_id = a.usr_id
   join devmst daf
     on a.frstol = daf.devcod
    and a.wh_id = daf.wh_id
   join users_view uv
     on b.usr_id = uv.usr_id
   left join (select distinct a.usr_id,
            j.jobcodeid,
            a.jobcodeid last_work_code,
            k.adj_start_time as start_time
       from kvi_adjustments k,
            jobcode j,
            kvi_summary a
      where a.kvisummaryintid = k.kvisummaryintid
        and j.jobcodeintid = k.jobcodeintid
        and a.status in ('C', 'A')
        and j.jobcodeid in ('LUNCH', 'OVRTBREAK', 'BREAK')) t
     on b.usr_id = t.usr_id
    and b.trndte < t.start_time
    and b.dlytrn_id = (select max(tmp.dlytrn_id)
                         from dlytrn tmp
                        where tmp.usr_id = b.usr_id
                          and tmp.trndte < t.start_time)
    and to_char(b.trndte, 'yyyy-mm-dd') = to_char(t.start_time, 'yyyy-mm-dd') 
    and a.usr_id = t.usr_id
    and a.trndte > t.start_time
    and a.dlytrn_id = (select min(tmp.dlytrn_id)
                     from dlytrn tmp
                    where tmp.usr_id = a.usr_id
                      and tmp.trndte > t.start_time)
    and to_char(a.trndte, 'yyyy-mm-dd') = to_char(t.start_time, 'yyyy-mm-dd') 
    and t.jobcodeid in ('LUNCH', 'OVRTBREAK', 'BREAK')
  where @usr_id_in:raw
    and to_char(b.trndte, 'yyyy-mm-dd hh24:mi') >= @start_dt
    and to_char(b.trndte, 'yyyy-mm-dd hh24:mi') <= @end_dt
    and floor((a.trndte - b.trndte) * 24 * 60) >= 5
    and not exists (select 'x' from dlytrn tmp where tmp.usr_id = b.usr_id and tmp.dlytrn_id > b.dlytrn_id and tmp.dlytrn_id < a.dlytrn_id)
  order by pin_no,
        break_date,
        last_pick_time]