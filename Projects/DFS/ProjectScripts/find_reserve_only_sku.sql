[select distinct prtnum
   from prtmst p
  where exists(select 'x'
                 from inventory_view iv,
                      locmst lm,
                      aremst am
                where iv.stoloc = lm.stoloc
                  and lm.arecod = am.arecod
                  and iv.prtnum = p.prtnum
                  and iv.prt_client_id = p.prt_client_id
                  and am.arecod in ('LQRR', 'WINR', 'TOBR')
                  and am.bldg_id = 'Greenwich')
    and not exists(select 'x'
                     from inventory_view iv2,
                          locmst lm2
                    where iv2.stoloc = lm2.stoloc
                      and iv2.prtnum = p.prtnum
                      and iv2.prt_client_id = p.prt_client_id
                      and lm2.arecod in ('LQRD', 'LQRDC', 'WIND', 'WINDC', 'TOBD', 'TOBDC', 'VLQRD', 'VLQRDC', 'VWIND', 'VWINDC'))]
|
[select invsum.prtnum,
        sum(invsum.untqty) totqty,
        invsum.arecod,
        invsum.untcas,
        prtmst_view.prtfam
   from invsum
   join prtmst_view
     on invsum.prtnum = prtmst_view.prtnum
    and invsum.prt_client_id = prtmst_view.prt_client_id
    and invsum.wh_id = prtmst_view.wh_id
  where invsum.prtnum = @prtnum
    and invsum.wh_id = 'SGDC'
    and invsum.arecod in ('LQRR', 'WINR', 'TOBR')
  group by invsum.prtnum,
        invsum.arecod,
        invsum.untcas,
        prtmst_view.prtfam]