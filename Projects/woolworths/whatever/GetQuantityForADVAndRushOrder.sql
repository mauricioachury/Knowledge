[select round(sum(ol.ordqty / decode(pf.pakuom, null, pf.untcas, pf.untpak))) ord_uom_qty,
        o.ordnum,
        o.ordtyp,
        to_char(o.adddte, 'yyyy-mm-dd hh24:mi:ss') adddte
   from ord o
   join ord_line ol
     on o.ordnum = ol.ordnum
    and o.wh_id = ol.wh_id
   join prtftp_view pf
     on ol.prtnum = pf.prtnum
    and ol.prt_client_id = pf.prt_client_id
    and ol.wh_id = pf.wh_id
    and pf.defftp_flg = 1
  where o.adddte > sysdate - 1.5
    and ordtyp in ('ADV', 'RUSH')
  group by o.ordnum,
        o.ordtyp,
        o.adddte
  order by ordnum]
|
[select nvl(sum(pv.appqty / pf.untqty), 0) pcked_uom_qty
   from pckwrk_view pv
   join prtftp_dtl pf
     on pv.prt_client_id = pf.prt_client_id
    and pv.prtnum = pf.prtnum
    and pv.wh_id = pf.wh_id
    and pv.ftpcod = pf.ftpcod
    and pv.pck_uom = pf.uomcod
  where pv.ordnum = @ordnum]
|
[select distinct ssv.trlr_stat,
        s.shpsts,
        am.host_ext_id
   from ship_struct_view ssv
   join shipment s
     on ssv.ship_id = s.ship_id
    and ssv.wh_id = s.wh_id
   join shipment_line sl
     on ssv.ship_id = sl.ship_id
    and ssv.wh_id = sl.wh_id
   join adrmst am
     on ssv.adr_id = am.adr_id
  where sl.ordnum = @ordnum] catch(-1403)
|
if (@? = -1403)
{
    [select am.host_ext_id
       from ord o
       join adrmst am
         on o.rt_adr_id = am.adr_id
      where o.ordnum = @ordnum]
}
|
if (@shpsts = 'S')
{
    publish data
     where ordnum = @ordnum
       and ordtyp = @ordtyp
       and adddte = @adddte
       and stgqty = @pcked_uom_qty
       and ord_uom_qty = @ord_uom_qty
       and dispatch_qty = 0
       and picking_qty = 0
       and host_ext_id = @host_ext_id
}
else if (@trlr_stat = 'D')
{
    publish data
     where ordnum = @ordnum
       and ordtyp = @ordtyp
       and adddte = @adddte
       and dispatch_qty = @pcked_uom_qty
       and ord_uom_qty = @ord_uom_qty
       and stgqty = 0
       and picking_qty = 0
       and host_ext_id = @host_ext_id
}
else
{
    publish data
     where ordnum = @ordnum
       and ordtyp = @ordtyp
       and adddte = @adddte
       and dispatch_qty = 0
       and stgqty = 0
       and ord_uom_qty = @ord_uom_qty
       and picking_qty = @pcked_uom_qty
       and host_ext_id = @host_ext_id
};