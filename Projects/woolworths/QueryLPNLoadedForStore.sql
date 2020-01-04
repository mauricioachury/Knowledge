publish data
  where load_dte = '2019-10-08'
    and host_ext_id = '4361'
    and arenam = 'Chiller'
|
[select uv.usr_id,
        uv.first_name ||', '||uv.last_name user_name,
        max(to_char(trndte, 'yyyy-mm-dd hh24:mi:ss')) load_time,
        aiv.lodnum,
        decode(am.bldg_id, 'AMBIENT', 'Ambient', 'Chiller') Department
   from ship_struct_view ssv
   join shipment_line sl
     on ssv.ship_id = sl.ship_id
   join all_inventory_view aiv
     on sl.ship_line_id = aiv.ship_line_id
   join trlr t
     on ssv.trlr_id = t.trlr_id
   join pckwrk_view pv
     on aiv.wrkref = pv.wrkref
   join aremst am
     on pv.srcare = am.arecod
    and pv.wh_id = am.wh_id
   join dlytrn d
     on aiv.lodnum = d.lodnum
    and d.actcod = 'TRLR_LOAD'
  join adrmst am
     on ssv.adr_id = am.adr_id
  join users_view uv
    on d.usr_id = uv.usr_id
  where t.trlr_stat = 'D'
    and am.bldg_id = decode(@arenam, 'Ambient', 'AMBIENT','TC')
    and to_char(d.trndte, 'yyyy-mm-dd') = @load_dte
    and am.host_ext_id = @host_ext_id
  group by uv.usr_id,
        uv.first_name,
        uv.last_name,
        aiv.lodnum,
        am.bldg_id];