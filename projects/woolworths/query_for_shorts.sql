1. Cancel pick by date, cancel user and pick zone.

publish data where startdte = '2019-01-01'
|
remote ('http://ncdwwmsasp0004:49000/service')
{
[select to_char (cp.candte,
                'yyyy-mm-dd') candte,
        pz.pck_zone_cod,
        decode(cp.can_usr_id, 'SYSTEM', 'SYSTEM_CANCEL', 'USER_CANCEL') canusr,
        count (*) wrkcnt
   from canpck cp join locmst lm on cp.srcloc = lm.stoloc
    and cp.wh_id = lm.wh_id join pck_zone pz on lm.pck_zone_id = pz.pck_zone_id
    and lm.wh_id = pz.wh_id
  where to_char(cp.candte, 'yyyy-mm-dd') >= @startdte
  group by pz.pck_zone_cod, to_char (cp.candte, 'yyyy-mm-dd'),
        decode(cp.can_usr_id, 'SYSTEM', 'SYSTEM_CANCEL', 'USER_CANCEL')
   order by candte, pck_zone_cod ]
}
&
[select to_char (cp.candte,
                'yyyy-mm-dd') candte,
        pz.pck_zone_cod,
        decode(cp.can_usr_id, 'SYSTEM', 'SYSTEM_CANCEL', 'USER_CANCEL') canusr,
        count (*) wrkcnt
   from canpck cp join locmst lm on cp.srcloc = lm.stoloc
    and cp.wh_id = lm.wh_id join pck_zone pz on lm.pck_zone_id = pz.pck_zone_id
    and lm.wh_id = pz.wh_id
  where to_char(cp.candte, 'yyyy-mm-dd') >= @startdte
  group by pz.pck_zone_cod, to_char (cp.candte, 'yyyy-mm-dd'),
        decode(cp.can_usr_id, 'SYSTEM', 'SYSTEM_CANCEL', 'USER_CANCEL')
   order by candte, pck_zone_cod]

2. Short by date

publish data where startdte = '2019-01-01'
|
remote ('http://ncdwwmsasp0004:49000/service')
{
 [select to_char (candte, 'yyyy-mm-dd') candte,
        count (*) short_count
   from canshort cp
  where to_char(cp.candte, 'yyyy-mm-dd') >= @startdte
  group by to_char (candte, 'yyyy-mm-dd')
  order by candte]
}
&
 [select to_char (candte, 'yyyy-mm-dd') candte,
        count (*) short_count
   from canshort cp
  where to_char(cp.candte, 'yyyy-mm-dd') >= @startdte
  group by to_char (candte, 'yyyy-mm-dd')
  order by candte]

3. Pick type

publish data where startdte = '2017-01-01'
|
remote ('http://ncdwwmsasp0004:49000/service')
{
[select to_char (pv.adddte, 'yyyy-mm-dd') adddte,
        pz.pck_zone_cod,
        pv.pck_uom,
        count (*) wrkcnt
   from pckwrk_view pv join locmst lm on pv.srcloc = lm.stoloc
    and pv.wh_id = lm.wh_id join pck_zone pz on lm.pck_zone_id = pz.pck_zone_id
    and lm.wh_id = pz.wh_id
  where to_char(pv.adddte, 'yyyy-mm-dd') >= @startdte
  group by pz.pck_zone_cod, pv.pck_uom, to_char (pv.adddte, 'yyyy-mm-dd')
   order by pck_zone_cod]
}
&
[select to_char (pv.adddte, 'yyyy-mm-dd') adddte,
        pz.pck_zone_cod,
        pv.pck_uom,
        count (*) wrkcnt
  from pckwrk_view pv join locmst lm on pv.srcloc = lm.stoloc
   and pv.wh_id = lm.wh_id join pck_zone pz on lm.pck_zone_id = pz.pck_zone_id
   and lm.wh_id = pz.wh_id
 where to_char(pv.adddte, 'yyyy-mm-dd') >= @startdte
 group by pz.pck_zone_cod, pv.pck_uom, to_char (pv.adddte, 'yyyy-mm-dd')
 order by pck_zone_cod]

4. For Assignment
remote ('http://ncdwwmsasp0004:49000/service')
{
 [select lstdte,
         pck_zone_cod,
         avg(lstpckuom) avg_lst_uom,
         count(distinct list_id) lst_cnt
   from (select max(to_char(pv.adddte, 'yyyy-mm-dd')) lstdte,
        pz.pck_zone_cod,
        pv.list_id,
        sum(pckqty / decode(pv.untpak, 0, pv.untcas, pv.untpak)) lstpckuom
   from pckwrk_view pv join locmst lm on pv.srcloc = lm.stoloc
    and pv.wh_id = lm.wh_id join pck_zone pz on lm.pck_zone_id = pz.pck_zone_id
    and lm.wh_id = pz.wh_id
  group by pz.pck_zone_cod,
           pv.list_id ) tmp
  group by tmp.pck_zone_cod, tmp.lstdte
  order by tmp.lstdte, tmp.pck_zone_cod]
}
&
[select lstdte,
        pck_zone_cod,
        avg(lstpckuom) avg_lst_uom,
        count(distinct list_id) lst_cnt
   from (select max(to_char(pv.adddte, 'yyyy-mm-dd')) lstdte,
       pz.pck_zone_cod,
       pv.list_id,
       sum(pckqty / decode(pv.untpak, 0, pv.untcas, pv.untpak)) lstpckuom
  from pckwrk_view pv join locmst lm on pv.srcloc = lm.stoloc
   and pv.wh_id = lm.wh_id join pck_zone pz on lm.pck_zone_id = pz.pck_zone_id
   and lm.wh_id = pz.wh_id
  group by pz.pck_zone_cod,
     pv.list_id ) tmp
  group by tmp.pck_zone_cod, tmp.lstdte
  order by tmp.lstdte, tmp.pck_zone_cod]

 5.  Order line
 remote ('http://ncdwwmsasp0004:49000/service')
 {
    [select to_char(ssv.dispatch_dte, 'yyyy-mm-dd') shpdte,
            sum(ol.ordqty / decode(pv.dspuom, 'IP', decode(sign(pf.untpak), 1, pf.untpak, pf.untcas), 'CS', pf.untcas, 'PA', pf.untpal)) dspuomqty,
            ol.prtnum,
            round(sum(ol.ordqty / pf.untpal), 2) palqty,
            round(sum(decode(sign(pf.untlay), 1, ol.ordqty / pf.untlay, 0)), 2) layqty
        from ord_line ol
        join shipment_line sl
          on ol.ordnum = sl.ordnum
         and ol.ordlin = sl.ordlin
         and ol.wh_id = sl.wh_id
        join prtmst_view pv
          on ol.prtnum = pv.prtnum
         and ol.prt_client_id = pv.prt_client_id
         and ol.wh_id = pv.wh_id
        join prtftp_view pf
          on pv.prtnum = pf.prtnum
         and pv.prt_client_id = pf.prt_client_id
         and pv.wh_id = pf.wh_id
         and pf.defftp_flg = 1
        join ship_struct_view ssv
          on ssv.ship_id = sl.ship_id
         and ssv.wh_id = sl.wh_id
       where dispatch_dte is not null
         and to_char(ssv.dispatch_dte, 'yyyy-mm-dd') >= '2019-02-18'
       group by to_char(ssv.dispatch_dte, 'yyyy-mm-dd'), ol.prtnum
      ]
 }
 &
 [select to_char(ssv.dispatch_dte, 'yyyy-mm-dd') shpdte,
            sum(ol.ordqty / decode(pv.dspuom, 'IP', decode(sign(pf.untpak), 1, pf.untpak, pf.untcas), 'CS', pf.untcas, 'PA', pf.untpal)) dspuomqty,
            ol.prtnum,
  ol.prtnum,
  round(sum(ol.ordqty / pf.untpal), 2) palqty,
  round(sum(decode(sign(pf.untlay), 1, ol.ordqty / pf.untlay, 0)), 2) layqty
from ord_line ol
join shipment_line sl
on ol.ordnum = sl.ordnum
and ol.ordlin = sl.ordlin
and ol.wh_id = sl.wh_id
join prtmst_view pv
on ol.prtnum = pv.prtnum
and ol.prt_client_id = pv.prt_client_id
and ol.wh_id = pv.wh_id
join prtftp_view pf
on pv.prtnum = pf.prtnum
and pv.prt_client_id = pf.prt_client_id
and pv.wh_id = pf.wh_id
and pf.defftp_flg = 1
join ship_struct_view ssv
on ssv.ship_id = sl.ship_id
and ssv.wh_id = sl.wh_id
where dispatch_dte is not null
  and to_char(ssv.dispatch_dte, 'yyyy-mm-dd') >= '2019-02-18'
group by to_char(ssv.dispatch_dte, 'yyyy-mm-dd'), ol.prtnum
]

6. PF and replenishment

remote ('http://ncdwwmsasp0004:49000/service')
{
   [select to_char(ssv.dispatch_dte, 'yyyy-mm-dd') shpdte,
           sum(ol.ordqty / decode(pv.dspuom, 'IP', decode(sign(pf.untpak), 1, pf.untpak, pf.untcas), 'CS', pf.untcas, 'PA', pf.untpal)) dspuomqty,
           ol.prtnum,
           r.loccnt asg_loccnt,
           sum(pf.untpal * r.loccnt * 1.1 / decode(pv.dspuom, 'IP', decode(sign(pf.untpak), 1, pf.untpak, pf.untcas), 'CS', pf.untcas, 'PA', pf.untpal)) asgloc_to_uomqty
       from ord_line ol
       join shipment_line sl
         on ol.ordnum = sl.ordnum
        and ol.ordlin = sl.ordlin
        and ol.wh_id = sl.wh_id
       join prtmst_view pv
         on ol.prtnum = pv.prtnum
        and ol.prt_client_id = pv.prt_client_id
        and ol.wh_id = pv.wh_id
       join prtftp_view pf
         on pv.prtnum = pf.prtnum
        and pv.prt_client_id = pf.prt_client_id
        and pv.wh_id = pf.wh_id
        and pf.defftp_flg = 1
       join ship_struct_view ssv
         on ssv.ship_id = sl.ship_id
        and ssv.wh_id = sl.wh_id
       join (select prtnum, prt_client_id, wh_id, count(distinct stoloc) loccnt
               from rplcfg 
              where wh_id = 'SLDC'
             group by prtnum, prt_client_id, wh_id) r
         on pv.prtnum = r.prtnum
        and pv.prt_client_id = r.prt_client_id
        and pv.wh_id = r.wh_id
      where to_char(ssv.dispatch_dte, 'yyyy-mm') = '2019-01'
      group by to_char(ssv.dispatch_dte, 'yyyy-mm-dd'), ol.prtnum]
}
&
   [select to_char(ssv.dispatch_dte, 'yyyy-mm-dd') shpdte,
           sum(ol.ordqty / decode(pv.dspuom, 'IP', decode(sign(pf.untpak), 1, pf.untpak, pf.untcas), 'CS', pf.untcas, 'PA', pf.untpal)) dspuomqty,
           ol.prtnum,
           r.loccnt asg_loccnt,
           sum(pf.untpal * r.loccnt * 1.1 / decode(pv.dspuom, 'IP', decode(sign(pf.untpak), 1, pf.untpak, pf.untcas), 'CS', pf.untcas, 'PA', pf.untpal)) asgloc_to_uomqty
       from ord_line ol
       join shipment_line sl
         on ol.ordnum = sl.ordnum
        and ol.ordlin = sl.ordlin
        and ol.wh_id = sl.wh_id
       join prtmst_view pv
         on ol.prtnum = pv.prtnum
        and ol.prt_client_id = pv.prt_client_id
        and ol.wh_id = pv.wh_id
       join prtftp_view pf
         on pv.prtnum = pf.prtnum
        and pv.prt_client_id = pf.prt_client_id
        and pv.wh_id = pf.wh_id
        and pf.defftp_flg = 1
       join ship_struct_view ssv
         on ssv.ship_id = sl.ship_id
        and ssv.wh_id = sl.wh_id
       join (select prtnum, prt_client_id, wh_id, count(distinct stoloc) loccnt
               from rplcfg 
              where wh_id = 'SLDC'
             group by prtnum, prt_client_id, wh_id) r
         on pv.prtnum = r.prtnum
        and pv.prt_client_id = r.prt_client_id
        and pv.wh_id = r.wh_id
      where to_char(ssv.dispatch_dte, 'yyyy-mm') = '2019-01'
      group by to_char(ssv.dispatch_dte, 'yyyy-mm-dd'), ol.prtnum]