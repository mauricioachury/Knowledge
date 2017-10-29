publish data
 where wh_id = 'LR1'
   and prtnum = '4283808'
   and dateRange =
[to_char(trndte, 'yyyy-mm-dd hh24:mi:ss') >= '2017-08-28 10:00:00'
 and to_char(trndte, 'yyyy-mm-dd hh24:mi:ss') <= '2017-09-1 10:00:00']
|
[select pv.prtnum SKU,
        pv.untpal PALLET_DENO,
        pv.untcas CARTON_DENO,
        sum(case when actcod = 'PALPCK' and oprcod = 'OC-PAPCK' and to_arecod = 'RDTS' then 1
                 else 0
            end) FULL_PALLET_PICKED,
        max(lpk.lst_pck_cnt) CASES_PICKED,
        sum(case when actcod = 'PALPCK' and oprcod = 'OC-PAPCK' and to_arecod = 'RDTS' then 1
                 else 0
            end) + max(lpk.lst_pck_cnt) TOTAL_PICK_FEQ,
        round(max(pv.caslen*pv.cashgt*pv.caswid * shpcas.totshpcas) * 2.54* 2.54 * 2.54 / 1000000, 2) TOTAL_SHIP_VOLUME,
        max(shpcas.totshpcas) TOTAL_SHIP_CASES
   from dlytrn
   join prtftp_view pv
     on dlytrn.prtnum = pv.prtnum
    and dlytrn.prt_client_id = pv.prt_client_id
    and dlytrn.wh_id = pv.wh_id
    and pv.defftp_flg = 1
   join (select prtnum,
                prt_client_id,
                wh_id,
                count(distinct list_id) lst_pck_cnt
           from pckwrk_view
          where wh_id = 'LR1'
            and appqty > 0
            and list_id is not null
          group by prtnum,
                prt_client_id,
                wh_id) lpk
     on pv.prtnum = lpk.prtnum
    and pv.prt_client_id = lpk.prt_client_id
    and pv.wh_id = lpk.wh_id
   join (select prtnum,
                prt_client_id,
                wh_id,
                sum(appqty / untcas) totshpcas
           from pckwrk_view
          where wh_id = 'LR1'
            and appqty > 0
          group by prtnum,
                prt_client_id,
                wh_id) shpcas
     on pv.prtnum = shpcas.prtnum
    and pv.prt_client_id = shpcas.prt_client_id
    and pv.wh_id = shpcas.wh_id
  where dlytrn.wh_id = @wh_id
    and @dateRange:raw
    and @+dlytrn.prtnum
    and pv.prtnum is not null
    and dlytrn.usr_id in (select usr_id
                            from les_usr_ath
                           where locale_id = 'SIMPLIFIED_CHINESE')
  group by pv.prtnum,
        pv.untpal,
        pv.untcas]