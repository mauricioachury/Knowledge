/* Use below to find LPN and device code where has the RF print screen hangs */
[select iv.lodnum,
        iv.stoloc
   from inventory_view iv
   join pckwrk_view pv
     on iv.wrkref = pv.wrkref
    and iv.wh_id = pv.wh_id
  where iv.stoloc in (select devcod
                        from rftmst)
  group by iv.lodnum,
        iv.stoloc
 having (count(distinct decode(pv.prtdte, null, 1, 2)) > 1)];