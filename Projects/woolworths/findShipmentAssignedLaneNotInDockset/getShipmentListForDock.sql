publish data
 where dckloc = 'DOR016'
   and shpsts = 'C'
|
[select sh.ship_id
   from shipment sh
   join stop
     on stop.stop_id = sh.stop_id
   join appt a
     on stop.car_move_id = a.car_move_id
  where a.stoloc = @dckloc
    and sh.shpsts <> 'C'
 union
 /* trailer has an appointment with a stoloc */
 select sh.ship_id
   from shipment sh
   join stop
     on stop.stop_id = sh.stop_id
   join car_move cm
     on cm.car_move_id = stop.car_move_id
   join trlr
     on trlr.trlr_id = cm.trlr_id
   join appt a
     on a.trlr_num = trlr.trlr_num
    and a.carcod = trlr.carcod
    and a.trlr_cod = /*#nobind*/ 'SHIP' /*#bind*/
  where a.stoloc = @dckloc
    and sh.shpsts <> 'C'
 union
 /* carrier move has an appointment with a slot_id */
 select sh.ship_id
   from shipment sh
   join stop
     on stop.stop_id = sh.stop_id
   join appt a
     on stop.car_move_id = a.car_move_id
   join locmst l
     on l.slot_id = a.slot_id
    and l.wh_id = a.wh_id
  where a.stoloc = @dckloc
    and sh.shpsts <> 'C'
 union
 /* trailer has an appointment with a slot_id */
 select sh.ship_id
   from shipment sh
   join stop
     on stop.stop_id = sh.stop_id
   join car_move cm
     on cm.car_move_id = stop.car_move_id
   join trlr
     on trlr.trlr_id = cm.trlr_id
   join appt a
     on a.trlr_num = trlr.trlr_num
    and a.carcod = trlr.carcod
    and a.trlr_cod = /*#nobind*/ 'SHIP' /*#bind*/
   join locmst l
     on l.slot_id = a.slot_id
    and l.wh_id = a.wh_id
  where a.stoloc = @dckloc
    and sh.shpsts <> 'C']
|
publish data
 where ship_id = @ship_id
   and dckloc = @dckloc