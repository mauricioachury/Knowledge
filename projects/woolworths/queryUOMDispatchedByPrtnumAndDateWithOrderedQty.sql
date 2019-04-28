publish data
 where wh_id = 'SLDC'
   and start_dte = '20190227'
   and end_dte = '20190228'
   and prtnum = '367804'
|
if (@prtnum = '')
{
    publish data
     where prtcls = ' 1 = 1'
}
else
{
    publish data
     where prtcls = " iv.prtnum = '" || @prtnum || "'"
}
|
[select sum(uom_qty) picked_uom_qty,
        sum(ord_uom_qty) ord_uom_qty,
        dispatch_dte,
        prtnum,
        lngdsc
   from (select pd.untpak,
                pd.untcas,
                iv.untqty,
                iv.prtnum,
                prtd.lngdsc,
                case when (pd.untpak > 0) then iv.untqty / pd.untcas
                     else iv.untqty / pd.untcas
                end uom_qty,
                case when (pd.untpak > 0) then ol.ordqty / pd.untcas
                     else ol.ordqty / pd.untcas
                end ord_uom_qty,
                to_char(pv.pckdte, 'YYYYMMDD') pckdte,
                to_char(ssv.dispatch_dte, 'yyyy-mm-dd') dispatch_dte,
                ssv.trlr_id,
                pv.schbat
           from all_inventory_view iv,
                shipment_line sl,
                ord_line ol,
                prtdsc prtd,
                prtftp_view pd,
                pckwrk_view pv,
                ship_struct_view ssv
          where iv.ship_line_id = sl.ship_line_id
            and sl.ordnum = ol.ordnum
            and sl.ordlin = ol.ordlin
            and iv.prtnum || '|' || iv.prt_client_id || '|' || @wh_id = prtd.colval
            and prtd.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
            and iv.prtnum = pd.prtnum
            and iv.prt_client_id = pd.prt_client_id
            and pd.wh_id = @wh_id
            and pd.ftpcod = iv.ftpcod
            and iv.ship_line_id = pv.ship_line_id
            and sl.ship_id = ssv.ship_id
            and iv.wrkref = pv.wrkref
            and @prtcls:raw
            and to_char(ssv.dispatch_dte, 'YYYYMMDD') >= @start_dte
            and to_char(ssv.dispatch_dte, 'YYYYMMDD') <= @end_dte) tmp
  group by prtnum,
        lngdsc,
       dispatch_dte
  order by prtnum]