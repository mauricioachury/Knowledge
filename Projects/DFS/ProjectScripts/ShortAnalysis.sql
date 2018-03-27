[select prtnum,
        rule_nam,
        rplref,
        rplcnt,
        pckqty short_qty
   from rplwrk
  where rplsts = 'F']
|
[select value ship_to_loc,
        @prtnum prtnum
   from alloc_rule_dtl
  where rule_nam = @rule_nam]
|
[select prtnum
   from prtmst_view pv
   join prtdsc pd
     on colnam = 'prtnum|prt_client_id|wh_id_tmpl'
    and colval = pv.prtnum || '|----|SGDC'
    and lngdsc not like 'GWP%'
  where not exists(select 'x'
                     from inventory_view iv,
                          locmst lm,
                          aremst am
                    where iv.stoloc = lm.stoloc
                      and lm.arecod = am.arecod
                      and iv.prtnum = pv.prtnum
                      and iv.prt_client_id = pv.prt_client_id
                      and lm.wh_id = am.wh_id
                      and am.bldg_id = 'Greenwich'
                      and am.arecod in ('LQRD', 'LQRDC', 'WIND', 'WINDC', 'TOBD', 'TOBDC', 'VLQRD', 'VLQRDC', 'VWIND', 'VWINDC', 'LQRR', 'WINR', 'TOBR'))
    and exists(select 'x'
                 from inventory_view iv,
                      locmst lm,
                      aremst am
                where iv.stoloc = lm.stoloc
                  and lm.arecod = am.arecod
                  and iv.prtnum = pv.prtnum
                  and iv.prt_client_id = pv.prt_client_id
                  and lm.wh_id = am.wh_id
                  and iv.inv_attr_str1 = @ship_to_loc
                  and am.bldg_id = 'Greenwich')
    and pv.prtnum = @prtnum
    and pv.wh_id = 'SGDC'] catch(-1403)
|
if (@? = 0)
{
    [select prtnum,
            pd.lngdsc,
            iv.stoloc,
            lm.arecod,
            iv.untcas,
            iv.invsts,
            sum(untqty) untqty,
            @rplref rplref,
            @rplcnt rplcnt,
            @short_qty short_qty,
            iv.inv_attr_str1 ship_to_loc
       from inventory_view iv,
            locmst lm,
            prtdsc pd
      where iv.stoloc = lm.stoloc
        and iv.inv_attr_str1 = @ship_to_loc
        and iv.prtnum = @prtnum
        and pd.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
        and pd.colval like iv.prtnum || '|%SGDC'
        and lm.arecod in (select arecod
                            from aremst
                           where bldg_id = 'Greenwich')
      group by prtnum,
            pd.lngdsc,
            iv.untcas,
            iv.invsts,
            lm.arecod,
            iv.inv_attr_str1,
            iv.stoloc] catch(-1403)
}