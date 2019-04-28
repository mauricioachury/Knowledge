publish data
 where start_dt = '06/01/2018'
   and end_dt = '06/02/2018'
|
[select pv.oprcod,
        dm.lngdsc,
        to_char(pv.pckdte, 'mm/dd/yyyy') picking_dte,
        round(sum(pv.appqty / pv.untcas)) picked_cases
   from pckwrk_view pv
   join dscmst dm
     on dm.colnam = 'oprcod|wh_id_tmpl'
    and dm.colval = pv.oprcod || '|' || pv.wh_id
  where pv.pckdte >= to_date(@start_dt, 'mm/dd/yyyy')
    and pv.pckdte <= to_date(@end_dt, 'mm/dd/yyyy')
  group by oprcod,
        dm.lngdsc,
        to_char(pv.pckdte, 'mm/dd/yyyy')
  order by picking_dte,
        dm.lngdsc,
        pv.oprcod];