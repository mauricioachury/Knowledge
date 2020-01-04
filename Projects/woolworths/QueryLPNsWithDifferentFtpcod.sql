[select iv.stoloc,
        iv.prtnum,
        sum(iv.untqty) untqty,
        iv.lodnum,
        iv.ftpcod,
        ol.max_ordqty,
        decode(sign(ol.max_ordqty - sum(iv.untqty)), 1, 'YES', 'NO') "posible Pallet Pick?"
   from inventory_view iv
   left
   join (select max(ordqty) max_ordqty,
                prtnum,
                prt_client_id,
                wh_id
           from ord_line
          where entdte > sysdate - 3
          group by prtnum,
                prt_client_id,
                wh_id) ol
     on iv.prtnum = ol.prtnum
    and iv.prt_client_id = ol.prt_client_id
    and iv.wh_id = ol.wh_id
  where iv.ship_line_id is null
    and iv.stoloc not like 'PERM%'
    and exists(select 'x'
                 from inventory_view iv2
                where iv2.prtnum = iv.prtnum
                  and iv2.prt_client_id = iv.prt_client_id
                  and iv2.wh_id = iv.wh_id
                  and iv2.ftpcod <> iv.ftpcod
                  and iv2.ship_line_id is null
                  and iv2.stoloc not like 'PERM%')
    and exists(select 'x'
                 from rplcfg r
                where r.prtnum = iv.prtnum
                  and r.prt_client_id = iv.prt_client_id
                  and r.wh_id = iv.wh_id
                  and (mov_zone_id = '10604' or mov_zone_id = '10632')
                  and exists(select 'x'
                               from pckwrk_view pv2
                              where pv2.srcloc = r.stoloc
                                and pv2.wh_id = r.wh_id
                                and pv2.pckqty > pv2.appqty))
  group by iv.prtnum,
        iv.stoloc,
        iv.ftpcod,
        iv.lodnum,
        ol.max_ordqty
  order by iv.prtnum,
        iv.stoloc,
        iv.ftpcod,
        iv.lodnum]