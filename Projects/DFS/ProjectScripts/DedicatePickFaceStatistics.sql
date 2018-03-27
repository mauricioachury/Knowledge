publish data
 where days = 40
|
[select tmp.shipped_cases,
        ceil(tmp.shipped_cases / tmp.pick_date_cnt) shipped_cases_per_day,
        ceil(r.maxunt / tmp.untcas) maxunt_by_case,
        ceil(r.minunt / tmp.untcas) minunt_by_case,
        tmp.untcas unit_per_case,
        r.maxunt,
        r.minunt,
        tmp.pick_date_cnt how_many_days_picked,
        r.prtnum,
        pv.prtfam,
        r.stoloc dedicated_location,
        r.arecod arecod,
        t.velzon loctyp,
        @days period_days
   from rplcfg r,
        tmp_loctype t,
        (select sum(appqty / untcas) shipped_cases,
                count(distinct to_char(pckdte, 'yyyy-mm-dd')) pick_date_cnt,
                max(untcas) untcas,
                prtnum,
                inv_attr_str1
           from pckwrk p
          where p.wrktyp = 'P'
            and p.pckdte > sysdate - @days
            and p.pcksts = 'C'
          group by prtnum,
                inv_attr_str1) tmp,
        prtmst_view pv
  where r.stoloc = t.stoloc
    and r.prtnum = tmp.prtnum
    and ((r.arecod like 'V%' and tmp.inv_attr_str1 = '1506') or (r.arecod not like 'V%' and tmp.inv_attr_str1 <> '1506'))
    and r.prtnum = pv.prtnum
    and r.prt_client_id = pv.prt_client_id
    and r.wh_id = pv.wh_id
  order by loctyp]