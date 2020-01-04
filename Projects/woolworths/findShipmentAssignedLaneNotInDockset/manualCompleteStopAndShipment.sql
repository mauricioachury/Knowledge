[select distinct iv.stoloc,
           iv.lodnum,
           s.shpsts, s.ship_id, ssv.car_move_id, sl.schbat, st.stop_cmpl_flg, st.stop_id, t.trlr_stat, t.trlr_id
   from ship_struct_view ssv
 join trlr t on ssv.trlr_id = t.trlr_id
 join shipment_line sl
   on ssv.ship_id = sl.ship_id
  and ssv.wh_id = sl.wh_id
 join shipment s
   on sl.ship_id = s.ship_id
 and sl.wh_id = s.wh_id
 join all_inventory_view iv
  on sl.ship_line_id = iv.ship_line_id
 and sl.wh_id = iv.wh_id
 join stop st
   on st.stop_id = s.stop_id
where 1=1 
    and t.trlr_id = 'TRL0030202'
    and st.stop_cmpl_flg = 0 and rownum <3
]

|
[update shipment set shpsts = 'C' where ship_id = @ship_id]
|
[update stop set stop_cmpl_flg = 1 where stop_id = @stop_id]
|
[update trlr set trlr_stat = 'L' where trlr_id = @trlr_id]
