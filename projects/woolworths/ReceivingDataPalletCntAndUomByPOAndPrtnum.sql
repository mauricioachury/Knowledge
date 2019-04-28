[select to_char(iv.adddte, 'yyyy-mm-dd') Received_Date,
           v.po_num,
           r.prtnum,
           count(distinct lodnum) Pallet_Received,
           sum(iv.untqty / decode(pm.dspuom, 'CS', pv.untcas, 'IP', pv.untpak, 'EA', 1, 'PA', pv.untpal)) Uom_Received,
           round(sum(iv.untqty / decode(pm.dspuom, 'CS', pv.untcas, 'IP', pv.untpak, 'EA', 1, 'PA', pv.untpal)) / count(distinct lodnum), 1) avg_uom_per_pallet
   from rcvinv v
    join rcvlin r
      on v.invnum = r.invnum
     and v.wh_id = r.wh_id
   join inventory_view iv
     on r.rcvkey = iv.rcvkey
   join prtftp_view pv
     on iv.prtnum = pv.prtnum
    and iv.prt_client_id = pv.prt_client_id
    and iv.wh_id = pv.wh_id
    and iv.ftpcod = pv.ftpcod
   join prtmst_view pm
     on r.prtnum = pm.prtnum
    and r.prt_client_id = pm.prt_client_id
    and r.wh_id = pm.wh_id
  where to_char(iv.adddte, 'yyyy-mm-dd') >= '2018-10-18'
    and to_char(iv.adddte, 'yyyy-mm-dd') <= '2018-10-18'
  group by to_char(iv.adddte, 'yyyy-mm-dd'),
           v.po_num,
           r.prtnum
  order by Received_Date,
               po_num,
               prtnum
   ]