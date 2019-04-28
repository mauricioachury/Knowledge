publish data
 where wh_id = 'SLDC'
    and start_dte = '20181201'
    and end_dte = '20190122'
    and prtnum = ''
|
if (@prtnum = '')
{
    publish data where prtcls = ' 1 = 1'
}
else 
{
    publish data where prtcls = " iv.prtnum = '" || @prtnum || "'"
}
|
[select sum(uom_qty) dispatched_uom_qty,
          prtnum
   from (select pd.untpak,
                pd.untcas,
                iv.untqty,
                iv.prtnum,
                case when (pd.untpak > 0) then iv.untqty / pd.untpak
                     else iv.untqty / pd.untcas
                end uom_qty,
                sl.schbat
           from invdtl_hist iv,
                shipment_line sl,
                prtftp_view pd,
                ship_struct_view ssv
          where iv.ship_line_id = sl.ship_line_id
            and iv.prtnum = pd.prtnum
            and iv.prt_client_id = pd.prt_client_id
            and @prtcls:raw
            and sl.wh_id = pd.wh_id
            and pd.wh_id = @wh_id
            and pd.ftpcod = iv.ftpcod
            and to_char(ssv.dispatch_dte, 'YYYYMMDD') >= @start_dte
            and to_char(ssv.dispatch_dte, 'YYYYMMDD') <= @end_dte
            and sl.ship_id = ssv.ship_id
            and ssv.trlr_stat = 'D') tmp
   group by prtnum]