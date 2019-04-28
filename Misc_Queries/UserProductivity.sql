publish data
 where start_dt = '06/01/2018'
   and end_dt = '06/02/2018'
|
[select uv.first_name || ',' || uv.last_name name,
        uv.usr_id,
        to_char(pv.pckdte, 'mm/dd/yyyy') picking_dte,
        count(distinct pv.srcloc) picked_loccnt,
        round(sum(pv.appqty / pv.untcas)) picked_cases
   from pckwrk_view pv
   join users_view uv
     on pv.last_pck_usr_id = uv.usr_id
  where pv.pckdte >= to_date(@start_dt, 'mm/dd/yyyy')
    and pv.pckdte <= to_date(@end_dt, 'mm/dd/yyyy')
  group by uv.first_name || ',' || uv.last_name,
        uv.usr_id,
        to_char(pv.pckdte, 'mm/dd/yyyy')
  order by uv.usr_id,
        picking_dte];