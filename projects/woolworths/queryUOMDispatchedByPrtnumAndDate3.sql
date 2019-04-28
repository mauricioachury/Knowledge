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
[select sum(uom_qty) picked_uom_qty,
          prtnum,
          lngdsc
   from (select pd.untpak,
                pd.untcas,
                iv.untqty,
                iv.prtnum,
                prtd.lngdsc,
                case when (pd.untpak > 0) then iv.untqty / pd.untpak
                     else iv.untqty / pd.untcas
                end uom_qty,
                pv.schbat
           from all_inventory_view iv,
                prtdsc prtd,
                prtftp_view pd,
                pckwrk_view pv
          where iv.prtnum||'|'||iv.prt_client_id||'|'||@wh_id = prtd.colval
            and prtd.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
            and iv.prtnum = pd.prtnum
            and iv.prt_client_id = pd.prt_client_id
            and pd.wh_id = @wh_id
            and pd.ftpcod = iv.ftpcod
            and iv.ship_line_id = pv.ship_line_id
            and iv.wrkref = pv.wrkref
            and @prtcls:raw
            and to_char(pv.pckdte, 'YYYYMMDD') >= @start_dte
            and to_char(pv.pckdte, 'YYYYMMDD') <= @end_dte) tmp
   group by prtnum, lngdsc
   order by prtnum]