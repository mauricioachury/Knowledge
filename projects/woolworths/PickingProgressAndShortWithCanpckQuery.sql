publish data
 where start_dte = '2018-10-28'
   and end_dte = '2018-10-28'
|
[select to_char(pw.pckdte, 'yyyy-mm-dd hh24') pick_hour,
        count(distinct pw.last_pck_usr_id) pck_usr_cnt,
        sum(pw.appqty / pv.untqty) uomPicked
   from pckwrk_view pw
   join prtftp_dtl pv
     on pw.prtnum = pv.prtnum
    and pw.prt_client_id = pv.prt_client_id
    and pw.wh_id = pv.wh_id
    and pw.pck_uom = pv.uomcod
  where to_char(pw.pckdte, 'yyyy-mm-dd') >= @start_dte
    and to_char(pw.pckdte, 'yyyy-mm-dd') <= @end_dte
  group by to_char(pw.pckdte, 'yyyy-mm-dd hh24')
  order by pick_hour desc]

publish data
 where start_dte = '2018-10-29'
   and end_dte = '2018-10-29'
|
[select sum(NumOfUom_TotalOrdered) cartons_ordered,
        sum(NumOfUom_TotalShipped) cartons_picked,
        round(sum(NumOfUom_TotalShipped) / sum(NumOfUom_TotalOrdered) * 100, 2) pct,
        sum(decode(sign(NumOfUom_Short_byCanpck - NumOfUom_Short_byOrder), 1, NumOfUom_Short_byOrder, NumOfUom_Short_byCanpck)) Cartons_short_canpck
   from (select o.rtcust,
                o.ordnum,
                ol.ordlin,
                ol.prtnum,
                nvl(pw.appqty, 0) / decode(pm.dspuom, 'CS', pv.untcas, 'IP', pv.untpak, 'EA', 1, 'PA', pv.untpal) NumOfUom_TotalShipped,
                ol.ordqty / decode(pm.dspuom, 'CS', pv.untcas, 'IP', pv.untpak, 'EA', 1, 'PA', pv.untpal) NumOfUom_TotalOrdered,
                nvl((cp.pckqty - cp.appqty), 0) / decode(pm.dspuom, 'CS', pv.untcas, 'IP', pv.untpak, 'EA', 1, 'PA', pv.untpal) NumOfUom_Short_byCanpck,
                (ol.ordqty - nvl(pw.pckqty, 0)) / decode(pm.dspuom, 'CS', pv.untcas, 'IP', pv.untpak, 'EA', 1, 'PA', pv.untpal) NumOfUom_Short_byOrder
           from ord o
           join ord_line ol
             on o.ordnum = ol.ordnum
            and o.wh_id = ol.wh_id
           join prtmst_view pm
             on ol.prtnum = pm.prtnum
            and ol.prt_client_id = pm.prt_client_id
            and ol.wh_id = pm.wh_id
           join prtftp_view pv
             on ol.prtnum = pv.prtnum
            and ol.prt_client_id = pv.prt_client_id
            and ol.wh_id = pv.wh_id
            and pv.defftp_flg = 1
           left
           join (select ordnum,
                        ordlin,
                        wh_id,
                        sum(dtl_pckqty) pckqty,
                        sum(dtl_appqty) appqty
                   from pckwrk_view
                  group by ordnum,
                        ordlin,
                        wh_id) pw
             on ol.ordnum = pw.ordnum
            and ol.ordlin = pw.ordlin
            and ol.wh_id = pw.wh_id
           left
           join (select cp1.ordnum,
                        cp1.ordlin,
                        cp1.wh_id,
                        sum(pckqty) pckqty,
                        sum(appqty) appqty
                   from canpck cp1
                   join (select srcloc,
                                ordnum,
                                ordlin,
                                min(candte) min_candte
                           from canpck cp2
                          where cp2.cancod = 'C-R-U'
                            and to_char(cp2.candte, 'yyyy-mm-dd') >= @start_dte
                            and to_char(cp2.candte, 'yyyy-mm-dd') <= @end_dte
                          group by srcloc,
                                ordnum,
                                ordlin) mc
                     on cp1.ordnum = mc.ordnum
                    and cp1.ordlin = mc.ordlin
                    and cp1.srcloc = mc.srcloc
                    and cp1.candte = mc.min_candte
                  where cp1.cancod = 'C-R-U'
                  group by cp1.ordnum,
                        cp1.ordlin,
                        cp1.wh_id) cp
             on ol.ordnum = cp.ordnum
            and ol.ordlin = cp.ordlin
            and ol.wh_id = cp.wh_id
          where to_char(ol.entdte, 'yyyy-mm-dd') >= @start_dte
            and to_char(ol.entdte, 'yyyy-mm-dd') <= @end_dte) tmp];
            
/* Canpck analysis, below query will return what canpck causes real short*/
[select cp.pckqty - cp.appqty canqty,
        cp.untcas,
        cp.untpak,
        (cp.pckqty - cp.appqty) / cp.untcas carton_cancelled,
        ol.ordqty / cp.untcas carton_ordered,
        ol.pckqty / cp.untcas carton_with_pick,
        iv.untqty / cp.untcas carton_available,
        iv.comqty / cp.untcas carton_commited,
        cp.srcloc,
        cp.prtnum,
        cp.cancod,
        cp.ordnum,
        cp.ordlin
   from canpck cp
   join (select max(l.ordqty) ordqty,
                sum(pv.dtl_pckqty) pckqty,
                l.ordnum,
                l.ordlin
           from ord_line l
           join pckwrk_view pv
             on l.ordnum = pv.ordnum
            and l.ordlin = pv.ordlin
            and l.wh_id = pv.wh_id
          group by l.ordnum,
                l.ordlin) ol
     on cp.ordnum = ol.ordnum
    and cp.ordlin = ol.ordlin
   join (select sum(untqty) untqty,
                sum(comqty) comqty,
                prtnum,
                prt_client_id,
                wh_id
           from invsum
          group by wh_id,
                prtnum,
                prt_client_id) iv
     on cp.prtnum = iv.prtnum
    and cp.prt_client_id = iv.prt_client_id
    and cp.wh_id = iv.wh_id
  where cp.candte > sysdate - 0.5
    and ol.ordqty > ol.pckqty];