[select iv.lodnum LPN,
        iv.prtnum,
        iv.untqty / pv.untcas num_cartons,
        iv.stoloc lpn_stoloc,
        lm.stoloc selection_location,
        pv.ftpcod,
        pv.cashgt single_carton_height,
        round(iv.untqty / pv.untcas / pv.caslvl* pv.cashgt, 2) total_cases_height,
        at.asset_hgt handing_unit_height,
        round(iv.untqty / pv.untcas / pv.caslvl* pv.cashgt + at.asset_hgt, 2) total_pallet_height,
        lm.lochgt selection_location_height,
        round(pv.caslen*pv.caswid*pv.cashgt * iv.untqty / pv.untcas + at.asset_len*at.asset_wid * at.asset_hgt, 2) pallet_volume,
        lm.maxqvl selection_max_volume
   from rplcfg r
   join prtftp_view pv
     on r.prtnum = pv.prtnum
    and r.prt_client_id = pv.prt_client_id
    and r.wh_id = pv.wh_id
   join locmst lm
     on r.stoloc = lm.stoloc
    and r.wh_id = lm.wh_id
   join (select sum(untqty) untqty,
                ftpcod,
                prtnum,
                prt_client_id,
                asset_typ,
                stoloc,
                lodnum,
                wh_id
           from inventory_view
          where ship_line_id is null
          group by ftpcod,
                prtnum,
                prt_client_id,
                asset_typ,
                stoloc,
                lodnum,
                wh_id) iv
     on pv.ftpcod = iv.ftpcod
    and pv.prtnum = iv.prtnum
    and pv.prt_client_id = iv.prt_client_id
    and pv.wh_id = iv.wh_id
   join asset_typ at
     on iv.asset_typ = at.asset_typ
  join loc_typ lt
    on lm.loc_typ_id = lt.loc_typ_id
  and lt.loc_typ not like 'CLS%'
  and lm.stoloc like '%1'
  and iv.stoloc not like '%1'
  where (iv.untqty / pv.untcas / pv.caslvl * pv.cashgt + at.asset_hgt > lm.lochgt)
     or (pv.caslen*pv.caswid*pv.cashgt * iv.untqty / pv.untcas + at.asset_len*at.asset_wid * at.asset_hgt > lm.maxqvl and lm.loccod = 'V')]