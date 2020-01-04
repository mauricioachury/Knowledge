/* building:
 * P: produce
 * C: Chiller
 * A: Ambient
 */
publish data
 where store_list = "('4304', '4348', '4359', '4173')"
   and building = 'A'
|
[select ssv.car_move_id load,
        am.host_ext_id,
        sum((appqty) / pd.untqty) total_uom_picked,
        sum((pckqty - appqty) / pd.untqty) total_uom_to_pick
   from ship_struct_view ssv
   join adrmst am
     on ssv.adr_id = am.adr_id
   join pckwrk_view pv
     on pv.ship_id = ssv.ship_id
   join prtftp_dtl pd
     on pv.ftpcod = pd.ftpcod
    and pv.prtnum = pd.prtnum
    and pv.prt_client_id = pv.prt_client_id
    and pv.wh_id = pv.wh_id
    and pv.pck_uom = pd.uomcod
  where am.host_ext_id in @store_list:raw
    and pv.list_id is not null
    and substr(pv.srcare, 1, 1) = @building
  group by ssv.car_move_id,
        am.host_ext_id
 having (sum((pckqty - appqty)) > 0)];