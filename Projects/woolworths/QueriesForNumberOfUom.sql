
/* 1. Below query get the number of uom that allocated today but not picked yet */

[select sum(uom_in_pick) uom_in_pick from (select sum(pw.pckqty/ decode(sign(pf.untpak), 1, pf.untpak, pf.untcas)) uom_in_pick,
           pw.pck_uom uomcod
           from pckwrk_hdr pw
           join prtftp_view pf
             on pf.prtnum =  pw.prtnum
            and pf.ftpcod = pw.ftpcod
            and pf.wh_id = pw.wh_id
            and (pf.paluom = pw.pck_uom or pf.casuom = pw.pck_uom or pf.pakuom = pw.pck_uom or pf.layuom = pw.pck_uom)
           where pw.wrktyp = 'P'
            and pw.wh_id = 'SLDC'
            and to_char(pw.adddte, 'YYYYMMDD') = to_char(sysdate , 'YYYYMMDD')
            and pw.appqty = 0
            and pw.wrktyp = 'P'
group by pw.pck_uom) tmp]



/* 2.  Below query get the number of uom that picked today */
[select sum(uom_in_pick) uom_in_pick from (select sum(pw.appqty/ decode(sign(pf.untpak), 1, pf.untpak, pf.untcas)) uom_in_pick,
           pw.pck_uom uomcod
           from pckwrk_hdr pw
           join prtftp_view pf
             on pf.prtnum =  pw.prtnum
            and pf.ftpcod = pw.ftpcod
            and pf.wh_id = pw.wh_id
            and (pf.paluom = pw.pck_uom or pf.casuom = pw.pck_uom or pf.pakuom = pw.pck_uom or pf.layuom = pw.pck_uom)
           where pw.wrktyp = 'P'
            and pw.wh_id = 'SLDC'
            and to_char(pw.pckdte, 'YYYYMMDD') = to_char(sysdate , 'YYYYMMDD')
            and pw.appqty > 0
            and pw.wrktyp = 'P'
group by pw.pck_uom) tmp]



/* 3. Below query return number of uom that downloaded today*/
[select sum(uom_qty) tot_uom_qty
            from (select pd.untpak,
           pd.untcas,
           ol.ordqty,
           ol.prtnum,
           ol.ordnum,
           ol.ordlin,
           case when (pd.untpak  > 0 ) then ol.ordqty / pd.untpak  else ol.ordqty / pd.untcas end uom_qty
   from ord_line ol,
        ord o,
         prtftp_view pd
  where ol.ordnum = o.ordnum
    and ol.prtnum = pd.prtnum
    and ol.prt_client_id = pd.prt_client_id
    and ol.wh_id = pd.wh_id
    and pd.wh_id = 'SLDC'
    and o.ordtyp <> 'XDOUT'
    and pd.defftp_flg = 1
    and to_char(ol.entdte, 'YYYYMMDD') = to_char(sysdate , 'YYYYMMDD')) tmp]



/* 4. Below query provide number of uom which is cancelled by cancel pick
 * with cancel code as 'No Picks to Ship' today.
 */
[select sum(uom_qty_cancelled) uom_qty_cancelled
   from (select sum((pw.pckqty) / decode(sign(pf.untpak), 1, pf.untpak, pf.untcas)) uom_qty_cancelled,
                pw.pck_uom uomcod,
                pw.wrkref,
                pw.can_usr_id
           from canpck pw
           join prtftp_view pf
             on pf.prtnum = pw.prtnum
            and pf.ftpcod = pw.ftpcod
            and pf.wh_id = pw.wh_id
          where pw.wrktyp = 'P'
            and pw.wh_id = 'SLDC'
            and pw.cancod = 'CANCEL'
            and to_char(pw.candte, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')
            and pw.ship_line_id is not null
          group by pw.pck_uom,
                pw.wrkref,
                pw.can_usr_id) tmp]


/* 5. Below query provide number of UOM dispatched today*/

[select sum(uom_qty) dispatched_uom_qty
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
            and sl.wh_id = pd.wh_id
            and pd.wh_id = 'SLDC'
            and pd.ftpcod = iv.ftpcod
            and to_char(ssv.dispatch_dte, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')
            and sl.ship_id = ssv.ship_id
            and ssv.trlr_stat = 'D') tmp]


/* 6. Below query provide number of pallets dispatched today for all types of pallets*/

[select sum(pallet_qty) pallet_qty,
        asset_typ
   from (select count(distinct il.lodnum) pallet_qty,
                il.asset_typ,
                sl.schbat
           from invdtl_hist iv,
                invsub_hist ib,
                invlod_hist il,
                shipment_line sl,
                prtftp_view pd,
                ship_struct_view ssv
          where iv.subnum = ib.subnum
            and ib.lodnum = il.lodnum
            and iv.ship_line_id = sl.ship_line_id
            and iv.prtnum = pd.prtnum
            and iv.prt_client_id = pd.prt_client_id
            and sl.wh_id = pd.wh_id
            and pd.wh_id = 'SLDC'
            and pd.ftpcod = iv.ftpcod
            and to_char(ssv.dispatch_dte, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')
            and sl.ship_id = ssv.ship_id
            and ssv.trlr_stat = 'D'
          group by il.asset_typ,
                sl.schbat) tmp
  group by tmp.asset_typ]
  
/* 7. Below query get the total number of UOM for each order(exclude crossdock order), for tot_pck_uom_qty:
 * emtpy: means order not planned into shipment.
 * 0:     means has pick but not picked yet.
 */

[select sum(ol_uom_qty) tot_ol_uom_qty,
        sum(pck_uom_qty) tot_pck_uom_qty,
        ordnum,
        ordtyp
   from (select pd.untpak,
                pd.untcas,
                ol.ordqty,
                ol.prtnum,
                ol.ordnum,
                o.ordtyp,
                ol.ordlin,
                case when (pd.untpak > 0) then ol.ordqty / pd.untpak
                     else ol.ordqty / pd.untcas
                end ol_uom_qty,
                case when (pd.untpak > 0) then pv.appqty / pd.untpak
                     else pv.appqty / pd.untcas
                end pck_uom_qty
           from prtftp_view pd,
                ord o,
                ord_line ol
           left
           join pckwrk_view pv
             on pv.ordnum = ol.ordnum
            and pv.ordlin = ol.ordlin
            and pv.ordsln = ol.ordsln
          where o.ordnum = ol.ordnum
            and o.wh_id = ol.wh_id
            and ol.prtnum = pd.prtnum
            and ol.prt_client_id = pd.prt_client_id
            and ol.wh_id = pd.wh_id
            and pd.wh_id = 'SLDC'
            and o.ordtyp <> 'XDOUT'
            and pd.defftp_flg = 1
            and to_char(ol.entdte, 'YYYYMMDD') = to_char(sysdate, 'YYYYMMDD')) tmp
  group by ordnum,
        ordtyp]