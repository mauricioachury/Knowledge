publish data
 where start_dt = '2018-06-08 09:00'
   and end_dt = '2018-06-08 20:00'
   and usr_id_in = "b.usr_id in ('8448')"
|
[select b.usr_id pin_no,
        b.dlytrn_id,
        a.dlytrn_id,
        uv.last_name || ',' || uv.first_name as user_name,
        to_char(b.trndte, 'yyyy-mm-dd') break_date,
        decode(dbt.devcod, null, nvl(b.tostol, b.frstol), b.frstol) last_pick_location,
        to_char(b.trndte, 'hh24:mi:ss') last_pick_time,
        0 uoms_picked,
        decode(daf.devcod, null, nvl(a.frstol, a.tostol), a.tostol) next_pick_location,
        to_char(a.trndte, 'hh24:mi:ss') next_pick_location_time,
        floor((a.trndte - b.trndte) * 24 * 60) time_in_between_locations,
        b.lodnum LPN
   from dlytrn b
   join dlytrn a
     on b.usr_id = a.usr_id
    and b.trndte >= to_date(@start_dt, 'yyyy-mm-dd hh24:mi')
    and b.trndte <= to_date(@end_dt, 'yyyy-mm-dd hh24:mi')
    and b.dlytrn_id = (select max(dlytrn_id)
                         from dlytrn t1
                        where t1.usr_id = b.usr_id
                          and t1.trndte <= a.trndte
                          and t1.dlytrn_id < a.dlytrn_id)
    and a.trndte >= to_date(@start_dt, 'yyyy-mm-dd hh24:mi')
    and a.trndte <= to_date(@end_dt, 'yyyy-mm-dd hh24:mi')
    and a.dlytrn_id = (select min(dlytrn_id)
                         from dlytrn t2
                        where t2.usr_id = b.usr_id
                          and t2.trndte >= b.trndte
                          and t2.dlytrn_id > b.dlytrn_id)
    and a.trndte >= 5 / 24 / 60.0 + b.trndte
   left
   join devmst dbt
     on b.tostol = dbt.devcod
    and b.wh_id = dbt.wh_id
   left
   join devmst daf
     on a.frstol = daf.devcod
    and a.wh_id = daf.wh_id
   join users_view uv
     on b.usr_id = uv.usr_id
  where @usr_id_in:raw
  order by pin_no,
        break_date,
        last_pick_time];



select b.usr_id pin_no,
b.dlytrn_id,
a.dlytrn_id,
uv.last_name || ',' || uv.first_name as user_name,
to_char(b.trndte, 'yyyy-mm-dd') break_date,
decode(dbt.devcod, null, nvl(b.tostol, b.frstol), b.frstol) last_pick_location,
to_char(b.trndte, 'hh24:mi:ss') last_pick_time,
0 uoms_picked,
decode(daf.devcod, null, nvl(a.frstol, a.tostol), a.tostol) next_pick_location,
to_char(a.trndte, 'hh24:mi:ss') next_pick_location_time,
floor((a.trndte - b.trndte) * 24 * 60) time_in_between_locations,
b.lodnum LPN
from users_view uv
join dlytrn b
on b.usr_id IN ('8448')
and b.trndte >= to_date('2018-06-08 09:00', 'yyyy-mm-dd hh24:mi')
and b.trndte <= to_date('2018-06-08 20:00', 'yyyy-mm-dd hh24:mi')
join dlytrn a
on b.usr_id = a.usr_id
and a.trndte >= to_date('2018-06-08 09:00', 'yyyy-mm-dd hh24:mi')
and a.trndte <= to_date('2018-06-08 20:00', 'yyyy-mm-dd hh24:mi')
and b.dlytrn_id = (select max(dlytrn_id)
                 from dlytrn t1
                where t1.usr_id = b.usr_id
                  and t1.usr_id = a.usr_id
                  and t1.dlytrn_id < a.dlytrn_id)
and a.dlytrn_id = (select min(dlytrn_id)
                 from dlytrn t2
                where t2.usr_id = b.usr_id
                  and t2.usr_id = a.usr_id
                  and t2.dlytrn_id > b.dlytrn_id)
--and a.trndte >= 5 / 24 / 60.0 + b.trndte
left
join devmst dbt
on b.tostol = dbt.devcod
and b.wh_id = dbt.wh_id
left
join devmst daf
on a.frstol = daf.devcod
and a.wh_id = daf.wh_id
join users_view uv
on b.usr_id = uv.usr_id
where rownum < 100
order by pin_no,
break_date,
last_pick_time;