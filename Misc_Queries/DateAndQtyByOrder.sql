publish data
 where start_dt = '06/01/2018'
   and end_dt = '06/01/2018'
|
[select o.ordnum,
        ot.fst_pckdte,
        s.stgdte,
        ssv.loddte,
        ssv.dispatch_dte,
        ot.ordqty,
        ot.appqty shpqty
   from ord o
   join (select sum(ol.ordqty) ordqty,
                min(fst_pckdte) fst_pckdte,
                sum(pv.appqty) appqty,
                ol.ordnum,
                sl.ship_id,
                ol.wh_id
           from ord_line ol
           join shipment_line sl
             on ol.ordnum = sl.ordnum
            and ol.ordlin = sl.ordlin
            and ol.wh_id = sl.wh_id
           join (select min(ph.pckdte) fst_pckdte,
                        sum(pd.appqty) appqty,
                        pd.ordnum,
                        pd.ordlin,
                        pd.wh_id
                   from pckwrk_dtl pd
                   join pckwrk_hdr ph
                     on pd.wrkref = ph.wrkref
                    and pd.wh_id = ph.wh_id
                  group by pd.ordnum,
                        pd.ordlin,
                        pd.wh_id) pv
             on ol.ordnum = pv.ordnum
            and ol.ordlin = pv.ordlin
            and ol.wh_id = pv.wh_id
          group by ol.ordnum,
                sl.ship_id,
                ol.wh_id) ot
     on o.ordnum = ot.ordnum
    and o.wh_id = ot.wh_id
   join shipment s
     on ot.ship_id = s.ship_id
    and ot.wh_id = s.wh_id
   join ship_struct_view ssv
     on ot.ship_id = ssv.ship_id
  where o.entdte >= to_date(@start_dt, 'mm/dd/yyyy')
    and o.entdte <= to_date(@end_dt, 'mm/dd/yyyy')
  order by o.ordnum];