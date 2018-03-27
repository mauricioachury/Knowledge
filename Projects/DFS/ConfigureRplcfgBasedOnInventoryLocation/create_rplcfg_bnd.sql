[delete
   from tmp_rplcfg_comment where 1=1] catch(-1403)
|
[delete from tmp_rplcfg where 1=1] catch(-1403)
|
[insert into tmp_rplcfg select * from rplcfg]
|
[select prtnum
   from prtmst_view pv
   join prtdsc pd
     on colnam = 'prtnum|prt_client_id|wh_id_tmpl'
     and colval = pv.prtnum || '|----|SGDC'
     and lngdsc not like 'GWP%'
  where exists(select 'x'
                 from inventory_view iv,
                      locmst lm,
                      aremst am
                where iv.stoloc = lm.stoloc
                  and lm.arecod = am.arecod
                  and iv.prtnum = pv.prtnum
                  and iv.prt_client_id = pv.prt_client_id
                  and lm.wh_id = am.wh_id
                  and am.bldg_id = 'Greenwich'
                  and am.arecod in ('LQRD', 'LQRDC', 'WIND', 'WINDC', 'TOBD', 'TOBDC', 'VLQRD', 'VLQRDC', 'VWIND', 'VWINDC', 'LQRR','WINR','TOBR')
                  and iv.inv_attr_str1 <> '1506')
    and not exists(select 'y'
                     from rplcfg r
                    where r.prtnum = pv.prtnum
                      and r.prt_client_id = pv.prt_client_id
                      and r.arecod not like 'V%'
                      and (exists(select 'z'
                                   from inventory_view iv2
                                  where iv2.prtnum = r.prtnum
                                    and iv2.prt_client_id = r.prt_client_id
                                    and iv2.stoloc = r.stoloc)
                          --or exists (select 'x' from locmst l where l.stoloc = r.stoloc and l.wh_id = r.wh_id and l.locsts = 'E')
                      ))
    and pv.dept_cod in ('10','11','22')
    and pv.wh_id = 'SGDC']
|
[select distinct velzon skutyp
   from tmp_prttype
  where prtnum = @prtnum] catch(-1403)
|
if (@? = 0)
{
    publish data
      where skutyp = @skutyp
}
else
{
    publish data
      where skutyp = 'NoType'
}
|
[select r.stoloc asgloc,
        r.arecod asgare
   from rplcfg r,
        locmst lm
  where r.stoloc = lm.stoloc
    and r.arecod = lm.arecod
    and r.wh_id = lm.wh_id
    and r.prtnum = @prtnum
    and r.arecod in ('LQRD', 'LQRDC', 'WIND', 'WINDC', 'TOBD', 'TOBDC')] catch(-1403)
|
if (@? = 0)
{
    [select *
       from rplcfg r2, locmst lm
      where r2.stoloc = lm.stoloc
        and r2.wh_id = lm.wh_id
        and (exists(select 'x'
                     from inventory_view i
                    where i.stoloc = r2.stoloc
                      and i.prtnum <> r2.prtnum)
              or (lm.locsts = 'E' and exists (select 'x'
                                                from inventory_view i,
                                                     locmst l2
                                               where i.prtnum = r2.prtnum
                                                 and i.stoloc = l2.stoloc
                                                 and l2.stoloc <> r2.stoloc
                                                 and l2.arecod = r2.arecod)))
        and r2.stoloc = @asgloc
        and r2.prtnum = @prtnum] catch(-1403)
    |
    if (@? = 0)
    {
        publish data
         where prtnum = @prtnum
           and skutyp = @skutyp
           and stoloc = @asgloc
           and type = 'OccupiedByOtherSKUInv'
           and delete_flg = 1
           and create_flg = 1
    }
    else
    {
        publish data
         where prtnum = @prtnum
           and skutyp = @skutyp
           and stoloc = @asgloc
           and type = 'ExistGoodAsgn'
           and delete_flg = 0
           and create_flg = 0
    }
}
else
{
    [select stoloc asgloc
       from rplcfg r
      where r.prtnum = @prtnum
        and r.arecod not like 'V%'] catch(-1403)
    |
    if (@? = 0)
    {
        publish data
         where prtnum = @prtnum
           and skutyp = @skutyp
           and asgloc = @asgloc
           and stoloc = 'LookLocWithType:' || @skutyp
           and type = 'AssignLoc, Area code mismatch with locmst.'
           and delete_flg = 1
           and create_flg = 1
    }
    else
    {
        publish data
        where prtnum = @prtnum
          and skutyp = @skutyp
          and stoloc = 'LookLocWithType:' || @skutyp
          and type = 'No rplcfg found.'
          and delete_flg = 0
          and create_flg = 1
    }
}
|
if (@delete_flg = 1)
{
    [select stoloc stoloc_to_del
       from rplcfg
      where prtnum = @prtnum
        and stoloc = @asgloc]
    |
    [update locmst
        set asgflg = 0,
            repflg = 0
      where stoloc = @stoloc_to_del
        and asgflg = 1] catch(-1403)
    |
    [delete
       from rplcfg
      where stoloc = @stoloc_to_del] catch(-1403)
    |
    [delete
       from poldat
      where polcod = 'STORE-ASG-LOC-STS-AFS'
        and rtstr1 = rtstr2
        and rtstr1 = @stoloc_to_del] catch(-1403)
    |
    [delete
       from poldat_hst
      where polcod = 'STORE-ASG-LOC-STS-AFS'
        and new_rtstr1 = new_rtstr2
        and new_rtstr1 = @stoloc_to_del] catch(-1403)
}
|
if (@create_flg = 1)
{
    if (@asgare != '')
    {
        [select lmnew.stoloc stoloc_to_crt,
                lmnew.arecod area_to_crt
           from inventory_view iv
           join locmst lmnew
             on iv.stoloc = lmnew.stoloc
           join locmst lmold
             on lmold.stoloc = @asgloc
           left outer join tmp_loctype ltnew
             on lmnew.stoloc = ltnew.stoloc
           left outer join tmp_loctype ltold
             on ltold.stoloc = lmold.stoloc
          where iv.stoloc = lmnew.stoloc
            and lmnew.arecod = lmold.arecod
            and lmnew.wh_id = lmold.wh_id
            and lmold.stoloc = @asgloc
            and lmold.arecod = @asgare
            and lmnew.arecod = @asgare
            and iv.prtnum = @prtnum
            and iv.inv_attr_str1 <> '1506'
            and nvl(ltnew.velzon, 'X') = nvl(ltold.velzon, 'X')
          order by lmnew.asgflg, lmnew.stoloc] catch(-1403) >> res
        |
        if (@? = -1403)
        {
            [select lmnew.stoloc stoloc_to_crt,
                    lmnew.arecod area_to_crt
               from locmst lmnew
               join locmst lmold
                 on lmold.stoloc = @asgloc
               left outer join tmp_loctype ltnew
                 on lmnew.stoloc = ltnew.stoloc
               left outer join tmp_loctype ltold
                 on ltold.stoloc = lmold.stoloc
              where lmnew.arecod = lmold.arecod
                and lmnew.wh_id = lmold.wh_id
                and lmold.stoloc = @asgloc
                and lmold.arecod = @asgare
                and lmnew.arecod = @asgare
                and lmnew.curqvl = 0
                and lmnew.pndqvl = 0
                and nvl(ltnew.velzon, 'X') = nvl(ltold.velzon, 'X')
              order by lmnew.asgflg, lmnew.stoloc] catch(-1403) >> res
            |
            if (@? = -1403)
            {
                publish data
                 where stop_flg = 1
            }
            else
            {
                publish top rows
                  where count = 1
                    and res = @res
            }
        }
        else
        {
            publish top rows
              where count = 1
                and res = @res
        }
        |
        if (@stop_flg = 1)
        {
            [insert into tmp_rplcfg_comment(prtnum, prtfam, stoloc, arecod, ActionType, lngdsc ) select @prtnum,
                   prtfam,
                   @asgloc,
                   @asgare,
                   'AT1',
                   'No avaialble location found from area:' || @asgare || ', dept_cod:' || pv.dept_cod
              from prtmst_view pv
             where pv.prtnum = @prtnum
               and wh_id = 'SGDC']
            |
            publish data
             where prtnum = @prtnum
               and skutyp = @skutyp
               and stoloc = @stoloc
               and type = @type
               and delete_flg = @delete_flg
               and create_flg = @create_flg
               and create_success = 0
               and create_comment = 'Failed, Can not figure out location for SKU:' || @prtnum
        }
        else
        {
            [select 'x'
               from rplcfg r
              where r.stoloc = @stoloc_to_crt
                and r.prtnum <> @prtnum
             union
             select 'x'
               from poldat
              where polcod = 'STORE-ASG-LOC-STS-AFS'
                and rtstr1 = @stoloc_to_crt] catch(-1403)
            |
            if (@? = 0)
            {
                [update locmst
                    set asgflg = 0,
                        repflg = 0
                  where stoloc = @stoloc_to_crt
                    and asgflg = 1] catch(-1403)
                |
                [delete
                   from rplcfg
                  where stoloc = @stoloc_to_crt] catch(-1403)
                |
                [delete
                   from poldat
                  where polcod = 'STORE-ASG-LOC-STS-AFS'
                    and rtstr1 = rtstr2
                    and rtstr1 = @stoloc_to_crt] catch(-1403)
                |
                [delete
                   from poldat_hst
                  where polcod = 'STORE-ASG-LOC-STS-AFS'
                    and new_rtstr1 = new_rtstr2
                    and new_rtstr1 = @stoloc_to_crt] catch(-1403)
            }
            |
            [select maxunt,
                    minunt
               from tmp_rplcfg r
              where r.prtnum = @prtnum
                and not exists(select 'x'
                                 from rplcfg
                                where prtnum = @prtnum
                                  and arecod = r.arecod)
                and r.arecod = @area_to_crt
              order by r.maxunt desc] >> res
            |
            publish top rows
             where count = 1
               and res = @res
            |
            [select sum(untqty) totinvqty
               from inventory_view iv
              where iv.stoloc = @stoloc_to_crt
                and iv.prtnum = @prtnum]
            |
            if (@totinvqty > @maxunt)
            {
                [select 'x'
                 from dual
                where substr(@stoloc_to_crt, 1, 1) >= 'M'
                  and substr(@stoloc_to_crt, 1, 1) <= 'P'
                  and substr(@stoloc_to_crt, 2, 2) >= '01'
                  and substr(@stoloc_to_crt, 2, 2) <= '03'] catch(-1403)
                |
                if (@? = 0)
                {
                    [select sum(untqty) maxunt,
                            max(untcas) minunt
                       from inventory_view iv
                      where iv.stoloc = @stoloc_to_crt]
                }
                else
                {
                    [select velzon
                       from tmp_loctype
                      where stoloc = @stoloc_to_crt
                        and velzon >= '1'
                        and velzon <= '2'] catch(-1403)
                    |
                    if (@? = 0)
                    {
                        [select decode(@velzon, '1', 4, '2', 2, 1) * sum(untqty) maxunt,
                                round(sum(untqty) / 2) minunt
                           from inventory_view iv
                          where iv.stoloc = @stoloc_to_crt]
                    }
                    else
                    {
                        [select sum(untqty) maxunt,
                                max(untcas) minunt
                           from inventory_view iv
                          where iv.stoloc = @stoloc_to_crt]
                    }
                }
            }
            |
            [update locmst
                set maxqvl = @maxunt,
                    def_maxqvl = @maxunt,
                    repflg = 1,
                    useflg = 1
              where wh_id = 'SGDC'
                and stoloc = @stoloc_to_crt]
            |
            {
                create replenishment configuration
                 WHERE wh_id = 'SGDC'
                   AND prtnum = @prtnum
                   AND prt_client_id = '----'
                   AND stoloc = @stoloc_to_crt
                   and arecod = @area_to_crt
                   AND invsts = 'AFS'
                   AND pctflg = '0'
                   AND maxunt = @maxunt
                   AND minunt = @minunt
                   AND maxloc = '1'
                   AND inc_pct_flg = '1'
                   AND inc_unt = '0'
                   AND rls_pct = '100'
                |
                [update rplcfg
                    set mod_usr_id = 'SAMNI'
                  where stoloc = @stoloc_to_crt];
                [select stoloc polloc
                   from rplcfg r
                  where r.prtnum = @prtnum
                    and r.arecod = @area_to_crt
                    and r.prt_client_id = '----'
                    and r.wh_id = 'SGDC'
                    and r.stoloc is not null
                    and not exists(select 'x'
                                     from poldat_view pv
                                    where pv.polcod = 'STORE-ASG-LOC-STS-AFS'
                                      and pv.polvar = 'prtnum'
                                      and polval = '----' || '|' || @prtnum
                                      and rtstr1 = r.stoloc
                                      and rtstr1 = rtstr2
                                      and rownum < 2)] catch(-1403)
                |
                if (@? = 0)
                {
                    create assigned location policy
                     where prtnum = @prtnum
                       and prt_client_id = '----'
                       and wh_id = 'SGDC'
                       and begloc = @polloc
                       and endloc = @polloc
                       and invsts = 'AFS'
                       and locasg = 1
                       and seqflg = 1
                    |
                    [update poldat_hst
                        set mod_usr_id = 'SAMNI'
                      where polcod = 'STORE-ASG-LOC-STS-AFS'
                        and polval like '----|' || @prtnum || '%']
                    |
                    [update poldat
                        set mod_usr_id = 'SAMNI'
                      where polcod = 'STORE-ASG-LOC-STS-AFS'
                        and polval like '----|' || @prtnum || '%']
                }
            }
            |
            [insert into tmp_rplcfg_comment(prtnum, prtfam, stoloc, arecod, ActionType, lngdsc )
              select @prtnum,
                     prtfam,
                     @stoloc_to_crt,
                     @area_to_crt,
                     'OK',
                     'Success created rplcfg for SKU:' || @prtnum || ' at loc:' || @stoloc_to_crt || ' at Area:' || @area_to_crt || ',deptcod:' || pv.dept_cod
                from prtmst_view pv
               where pv.prtnum = @prtnum
                 and wh_id = 'SGDC']
            |
            publish data
             where prtnum = @prtnum
               and skutyp = @skutyp
               and stoloc = @stoloc
               and type = @type
               and delete_flg = @delete_flg
               and create_flg = @create_flg
               and create_success = 1
               and create_comment = 'Success, overrided to new location.'
        }
    }
    else
    {
        /* SKU no rplcfg*/
        
        [select lm.stoloc stoloc_to_crt,
                lm.arecod area_to_crt
           from inventory_view iv,
                locmst lm,
                prtmst_view pv
          where iv.prtnum = pv.prtnum
            and iv.prt_client_id = pv.prt_client_id
            and pv.wh_id = lm.wh_id
            and decode(lm.arecod, 'LQRD', 'L', 'LQRDC', 'L', 
                                     'WIND', 'W', 'WINDC', 'W', 
                                     'TOBD', 'T', 'TOBDC', 'T', 'XXX') = decode(pv.dept_cod, '10','L','11', 'W', '22', 'T', 'YYY')
            and iv.stoloc = lm.stoloc
            and lm.arecod in ('LQRD', 'LQRDC', 'WIND', 'WINDC', 'TOBD', 'TOBDC')
            and iv.prtnum = @prtnum
            and iv.inv_attr_str1 <> '1506'
          group by lm.stoloc, lm.arecod
          order by lm.stoloc] catch(-1403) >> res
         |
         if (@? = 0)
         {
             publish top rows
               where count = 1
                 and res = @res
             |
             [select 'x'
                from dual
               where substr(@stoloc_to_crt, 1, 1) >= 'M'
                 and substr(@stoloc_to_crt, 1, 1) <= 'P'
                 and substr(@stoloc_to_crt, 2, 2) >= '01'
                 and substr(@stoloc_to_crt, 2, 2) <= '03'] catch(-1403)
             |
             if (@? = 0)
             {
                 [select sum(untqty) maxunt,
                         max(untcas) minunt
                    from inventory_view iv
                   where iv.stoloc = @stoloc_to_crt]
             }
             else
             {
                 [select velzon
                    from tmp_loctype
                   where stoloc = @stoloc_to_crt
                     and velzon >= '1'
                     and velzon <= '2'] catch(-1403)
                 |
                 if (@? = 0)
                 {
                     [select decode(@velzon, '1', 4, '2', 2, 1) * sum(untqty) maxunt,
                             round(sum(untqty) / 2) minunt
                        from inventory_view iv
                       where iv.stoloc = @stoloc_to_crt]
                 }
                 else
                 {
                     [select sum(untqty) maxunt,
                             max(untcas) minunt
                        from inventory_view iv
                       where iv.stoloc = @stoloc_to_crt]
                 }
             }
             |
             [select 'x'
                from rplcfg r
               where r.stoloc = @stoloc_to_crt
                 and r.prtnum <> @prtnum
              union 
              select 'x'
                from poldat
               where polcod = 'STORE-ASG-LOC-STS-AFS'
                 and rtstr1 = @stoloc_to_crt] catch(-1403)
             |
             if (@? = 0)
             {
                 [update locmst
                     set asgflg = 0,
                         repflg = 0
                   where stoloc = @stoloc_to_crt
                     and asgflg = 1] catch(-1403)
                 |
                 [delete
                    from rplcfg
                   where stoloc = @stoloc_to_crt] catch(-1403)
                 |
                 [delete
                    from poldat
                   where polcod = 'STORE-ASG-LOC-STS-AFS'
                     and rtstr1 = rtstr2
                     and rtstr1 = @stoloc_to_crt] catch(-1403)
                 |
                 [delete
                    from poldat_hst
                   where polcod = 'STORE-ASG-LOC-STS-AFS'
                     and new_rtstr1 = new_rtstr2
                     and new_rtstr1 = @stoloc_to_crt] catch(-1403)
             }
             |
             [update locmst
                 set maxqvl = @maxunt,
                     def_maxqvl = @maxunt,
                     repflg = 1,
                     useflg = 1
               where wh_id = 'SGDC'
                 and stoloc = @stoloc_to_crt]
             |
             {
                create replenishment configuration
                  WHERE wh_id = 'SGDC'
                    AND prtnum = @prtnum
                    AND prt_client_id = '----'
                    AND stoloc = @stoloc_to_crt
                    and arecod = @area_to_crt
                    AND invsts = 'AFS'
                    AND pctflg = '0'
                    AND maxunt = @maxunt
                    AND minunt = @minunt
                    AND maxloc = '1'
                    AND inc_pct_flg = '1'
                    AND inc_unt = '0'
                    AND rls_pct = '100'
                 |
                 [update rplcfg
                     set mod_usr_id = 'SAMNI'
                   where stoloc = @stoloc_to_crt];
                 [select stoloc polloc
                    from rplcfg r
                   where r.prtnum = @prtnum
                     and r.arecod = @area_to_crt
                     and r.prt_client_id = '----'
                     and r.wh_id = 'SGDC'
                     and r.stoloc is not null
                     and not exists(select 'x'
                                      from poldat_view pv
                                     where pv.polcod = 'STORE-ASG-LOC-STS-AFS'
                                       and pv.polvar = 'prtnum'
                                       and polval = '----' || '|' || @prtnum
                                       and rtstr1 = r.stoloc
                                       and rtstr1 = rtstr2
                                       and rownum < 2)] catch(-1403)
                 |
                 if (@? = 0)
                 {
                     create assigned location policy
                      where prtnum = @prtnum
                        and prt_client_id = '----'
                        and wh_id = 'SGDC'
                        and begloc = @polloc
                        and endloc = @polloc
                        and invsts = 'AFS'
                        and locasg = 1
                        and seqflg = 1
                     |
                     [update poldat_hst
                         set mod_usr_id = 'SAMNI'
                       where polcod = 'STORE-ASG-LOC-STS-AFS'
                         and polval like '----|' || @prtnum || '%']
                     |
                     [update poldat
                         set mod_usr_id = 'SAMNI'
                       where polcod = 'STORE-ASG-LOC-STS-AFS'
                         and polval like '----|' || @prtnum || '%']
                 }
             }
             |
             [insert into tmp_rplcfg_comment(prtnum, prtfam, stoloc, arecod, ActionType, lngdsc )
             select @prtnum,
                    prtfam,
                    @stoloc_to_crt,
                    @area_to_crt,
                    'OK',
                    'Success created rplcfg for SKU:' || @prtnum || ' at loc:' || @stoloc_to_crt || ' at Area:' || @area_to_crt || ', dept_cod:' || pv.dept_cod
               from prtmst_view pv
              where pv.prtnum = @prtnum
                and wh_id = 'SGDC']
             |
             publish data
             where prtnum = @prtnum
               and skutyp = @skutyp
               and stoloc = @stoloc
               and type = @type
               and delete_flg = @delete_flg
               and create_flg = @create_flg
               and create_success = 1
               and create_comment = 'Success for SKU without rplcfg.'
         }
         else
         {
             [select lm.arecod inv_arecod,
                     pv.dept_cod inv_dept_cod
                from inventory_view iv,
                     locmst lm,
                     prtmst_view pv
               where iv.prtnum = pv.prtnum
                 and iv.prt_client_id = pv.prt_client_id
                 and pv.wh_id = lm.wh_id
                 and iv.stoloc = lm.stoloc
                 and lm.arecod in ('LQRD', 'LQRDC', 'WIND', 'WINDC', 'TOBD', 'TOBDC')
                 and iv.prtnum = @prtnum] catch(-1403)
             |
             if (@? = 0)
             {
                 [select 'x' from dual
                    where decode(@inv_arecod, 'LQRD', 'L', 'LQRDC', 'L', 
                                           'WIND', 'W', 'WINDC', 'W',
                                           'TOBD', 'T', 'TOBDC', 'T', 'XXX') <> decode(@inv_dept_cod, '10','L','11', 'W', '22', 'T', 'YYY')
                 ]
                 |
                 [insert into tmp_rplcfg_comment(prtnum, prtfam, stoloc, arecod, ActionType, lngdsc )
                 select @prtnum,
                        pv.dept_cod,
                        iv.stoloc,
                        lm.arecod,
                        'AT2',
                        'Failed, Area code:' || lm.arecod || ' where inventory sit does not match department:' || pv.dept_cod
                   from inventory_view iv,
                        locmst lm,
                        prtmst_view pv
                  where iv.prtnum = pv.prtnum
                    and iv.prt_client_id = pv.prt_client_id
                    and iv.stoloc = lm.stoloc
                    and pv.prtnum = @prtnum
                    and lm.wh_id = pv.wh_id
                    and lm.arecod in ('LQRD', 'LQRDC', 'WIND', 'WINDC', 'TOBD', 'TOBDC')
                    and pv.wh_id = 'SGDC']
                 |
                 publish data
                 where prtnum = @prtnum
                   and skutyp = @skutyp
                   and stoloc = @stoloc
                   and type = @type
                   and delete_flg = @delete_flg
                   and create_flg = @create_flg
                   and create_success = 0
                   and create_comment = 'Failed, Area:' || @inv_arecod || ' and dept_cod:' || @dept_cod || ' mismatch for SKU:' || @prtnum
             }
             else
             {
                 [select lm.stoloc inv_stoloc,
                         lm.arecod inv_arecod,
                         pv.dept_cod inv_dept_cod,
                         sum(untqty) lpnqty,
                         max(untcas) untcas
                    from inventory_view iv,
                         locmst lm,
                         prtmst_view pv
                   where iv.prtnum = pv.prtnum
                     and iv.prt_client_id = pv.prt_client_id
                     and pv.wh_id = lm.wh_id
                     and iv.stoloc = lm.stoloc
                     and lm.arecod in ('LQRR', 'WINR', 'TOBR')
                     and iv.prtnum = @prtnum
                     and iv.inv_attr_str1 <> '1506'
                     group by lm.stoloc,
                              lm.arecod,
                              pv.dept_cod
                     order by lpnqty desc] catch(-1403) >> res
                  |
                  if (@? = 0)
                  {
                      publish top rows
                        where count = 1
                          and res = @res
                      |
                      [select nvl(avg(shpqty), 0) avg_shpqty
                         from tmp_sku_shpqty
                        where prtnum = @prtnum
                          and inv_attr_str1 <> '1506'] catch(-1403)
                      |
                      [select rcvqty rcv_lpnqty
                         from tmp_sku_rcvqty
                        where prtnum = @prtnum
                        order by rcvcnt desc,
                              rcvqty desc] catch(-1403) >> res
                      |
                      if (@? = -1403)
                      {
                          publish data
                           where lpnqty = @lpnqty
                      }
                      else
                      {
                          publish top rows
                           where count = 1
                             and res = @res
                          |
                          publish data
                           where lpnqty = @rcv_lpnqty
                      }
                      |
                      if (@avg_shpqty > @lpnqty / 2.0)
                      {
                          publish data where prt_velzon = '2'
                      }
                      else
                      {
                          publish data where prt_velzon = '3'
                      }
                      |
                      [select decode(nvl(@prt_velzon,'B'),  '1', decode(@inv_dept_cod, '10', 'LQRD', '11', 'WIND', '22', 'TOBD'),
                                                            '2', decode(@inv_dept_cod, '10', 'LQRD', '11', 'WIND', '22', 'TOBD'),
                                                            '3', decode(@inv_dept_cod, '10', 'LQRDC','11', 'WINDC', '22', 'TOBDC'),
                                                            '4', decode(@inv_dept_cod, '10', 'LQRDC','11', 'WINDC', '22', 'TOBDC'), 'XXX') dstare
                       from dual]
                       |
                       [select stoloc stoloc_to_crt,
                               arecod area_to_crt
                          from locmst
                         where arecod = @dstare
                           and asgflg = 0
                           and locsts = 'E'
                         order by stoloc] catch(-1403)>> res
                       |
                       if (@? = -1403)
                       {
                           [insert into tmp_rplcfg_comment(prtnum, prtfam, stoloc, arecod, ActionType, lngdsc )
                           select @prtnum,
                                  pv.prtfam,
                                  iv.stoloc,
                                  lm.arecod,
                                  'AT3',
                                  'Failed, SKU:' || @prtnum || ',dept_cod:' || pv.dept_cod || ' only exists at reserve area:' || lm.arecod || ', but no available location from dedicate area:' || @dstare ||'.'
                             from inventory_view iv,
                                  locmst lm,
                                  prtmst_view pv
                            where iv.prtnum = pv.prtnum
                              and iv.prt_client_id = pv.prt_client_id
                              and iv.stoloc = lm.stoloc
                              and pv.prtnum = @prtnum
                              and lm.wh_id = pv.wh_id
                              and iv.inv_attr_str1 = @inv_attr_str1
                              and lm.arecod in ('LQRR','TOBR','WINR')
                              and pv.wh_id = 'SGDC']
                           |
                           publish data
                             where prtnum = @prtnum
                               and skutyp = @skutyp
                               and stoloc = @stoloc
                               and type = @type
                               and delete_flg = @delete_flg
                               and create_flg = @create_flg
                               and create_success = 0
                               and create_comment = 'Failed, SKU:' || @prtnum || ', dept_cod:' || @inv_dept_cod || ' only exists at reserve area, e.g, loc:' || @inv_stoloc || ', Arecod:' || @inv_arecod
                       }
                       else
                       {
                           publish top rows
                             where count = 1
                               and res = @res
                           |
                           [select 'x'
                              from dual
                             where substr(@stoloc_to_crt, 1, 1) >= 'M'
                               and substr(@stoloc_to_crt, 1, 1) <= 'P'
                               and substr(@stoloc_to_crt, 2, 2) >= '01'
                               and substr(@stoloc_to_crt, 2, 2) <= '03'] catch(-1403)
                           |
                           if (@? = 0)
                           {
                               [select 2 * @untcas maxunt,
                                       @untcas minunt
                                  from dual]
                           }
                           else
                           {
                               [select velzon
                                  from tmp_loctype
                                 where stoloc = @stoloc_to_crt
                                   and velzon >= '1'
                                   and velzon <= '2'] catch(-1403)
                               |
                               if (@? = 0)
                               {
                                   [select decode(@velzon, '1', 4, '2', 2, 1) * @lpnqty maxunt,
                                           round(@lpnqty / 2) minunt
                                      from dual]
                               }
                               else
                               {
                                   [select 2 * @untcas maxunt,
                                           @untcas minunt
                                     from dual]
                               }
                           }
                           |
                           [select 'x'
                              from rplcfg r
                             where r.stoloc = @stoloc_to_crt
                               and r.prtnum <> @prtnum
                            union 
                            select 'x'
                              from poldat
                             where polcod = 'STORE-ASG-LOC-STS-AFS'
                               and rtstr1 = @stoloc_to_crt] catch(-1403)
                         |
                         if (@? = 0)
                         {
                             [update locmst
                                 set asgflg = 0,
                                     repflg = 0
                               where stoloc = @stoloc_to_crt
                                 and asgflg = 1] catch(-1403)
                             |
                             [delete
                                from rplcfg
                               where stoloc = @stoloc_to_crt] catch(-1403)
                             |
                             [delete
                                from poldat
                               where polcod = 'STORE-ASG-LOC-STS-AFS'
                                 and rtstr1 = rtstr2
                                 and rtstr1 = @stoloc_to_crt] catch(-1403)
                             |
                             [delete
                                from poldat_hst
                               where polcod = 'STORE-ASG-LOC-STS-AFS'
                                 and new_rtstr1 = new_rtstr2
                                 and new_rtstr1 = @stoloc_to_crt] catch(-1403)
                         }
                         |
                         [update locmst
                             set maxqvl = @maxunt,
                                 def_maxqvl = @maxunt,
                                 repflg = 1,
                                 useflg = 1
                           where wh_id = 'SGDC'
                             and stoloc = @stoloc_to_crt]
                           |
                           {
                              create replenishment configuration
                                WHERE wh_id = 'SGDC'
                                  AND prtnum = @prtnum
                                  AND prt_client_id = '----'
                                  AND stoloc = @stoloc_to_crt
                                  and arecod = @area_to_crt
                                  AND invsts = 'AFS'
                                  AND pctflg = '0'
                                  AND maxunt = @maxunt
                                  AND minunt = @minunt
                                  AND maxloc = '1'
                                  AND inc_pct_flg = '1'
                                  AND inc_unt = '0'
                                  AND rls_pct = '100'
                               |
                               [update rplcfg
                                   set mod_usr_id = 'SAMNI'
                                 where stoloc = @stoloc_to_crt];
                               [select stoloc polloc
                                  from rplcfg r
                                 where r.prtnum = @prtnum
                                   and r.arecod = @area_to_crt
                                   and r.prt_client_id = '----'
                                   and r.wh_id = 'SGDC'
                                   and r.stoloc is not null
                                   and not exists(select 'x'
                                                    from poldat_view pv
                                                   where pv.polcod = 'STORE-ASG-LOC-STS-AFS'
                                                     and pv.polvar = 'prtnum'
                                                     and polval = '----' || '|' || @prtnum
                                                     and rtstr1 = r.stoloc
                                                     and rtstr1 = rtstr2
                                                     and rownum < 2)] catch(-1403)
                               |
                               if (@? = 0)
                               {
                                   create assigned location policy
                                    where prtnum = @prtnum
                                      and prt_client_id = '----'
                                      and wh_id = 'SGDC'
                                      and begloc = @polloc
                                      and endloc = @polloc
                                      and invsts = 'AFS'
                                      and locasg = 1
                                      and seqflg = 1
                                   |
                                   [update poldat_hst
                                       set mod_usr_id = 'SAMNI'
                                     where polcod = 'STORE-ASG-LOC-STS-AFS'
                                       and polval like '----|' || @prtnum || '%']
                                   |
                                   [update poldat
                                       set mod_usr_id = 'SAMNI'
                                     where polcod = 'STORE-ASG-LOC-STS-AFS'
                                       and polval like '----|' || @prtnum || '%']
                               }
                           }
                       }
                  }
                  else
                  {
                      [insert into tmp_rplcfg_comment(prtnum, prtfam, stoloc, arecod, ActionType, lngdsc )
                      select @prtnum,
                             pv.prtfam,
                             '',
                             '',
                             'AT4',
                             'Failed, SKU:' || @prtnum || ' NOT exists at reserve area, for ship to loc:' || @inv_attr_str1 ||', Skip.'
                        from prtmst_view pv
                       where pv.prtnum = @prtnum
                         and pv.wh_id = 'SGDC']
                      |
                      publish data
                        where prtnum = @prtnum
                          and skutyp = @skutyp
                          and stoloc = @stoloc
                          and type = @type
                          and delete_flg = @delete_flg
                          and create_flg = @create_flg
                          and create_success = 0
                          and create_comment = 'Failed, SKU:' || @prtnum || ' NOT exists at reserve area, for ship to loc:' || @inv_attr_str1 ||', Skip.'
                  }
             }
         }
    }
};
[select distinct stoloc stoloc_dup
 from rplcfg
where invsts = 'AFS'
  and exists(select 'x'
               from inventory_view i
              where i.stoloc = rplcfg.stoloc
                and i.prtnum <> rplcfg.prtnum)
  and arecod not like 'V%'] catch(-1403)
|
if (@? = 0)
{
    [update locmst
     set asgflg = 0,
         repflg = 0
    where stoloc = @stoloc_dup
     and asgflg = 1] catch(-1403)
    |
    [delete
    from rplcfg
    where stoloc = @stoloc_dup] catch(-1403)
    |
    [delete
    from poldat
    where polcod = 'STORE-ASG-LOC-STS-AFS'
     and rtstr1 = rtstr2
     and rtstr1 = @stoloc_dup] catch(-1403)
    |
    [delete
    from poldat_hst
    where polcod = 'STORE-ASG-LOC-STS-AFS'
     and new_rtstr1 = new_rtstr2
     and new_rtstr1 = @stoloc_dup] catch(-1403)
}
;
[select count(prtnum) ActivePrtCnt
   from prtmst_view pv
  where pv.wh_id = 'SGDC'
    and exists (select 'x'
                  from inventory_view iv,
                       locmst lm
                  where iv.stoloc = lm.stoloc
                    and lm.arecod in (select arecod
                                        from aremst
                                       where bldg_id = 'Greenwich')
                    and lm.arecod in ('LQRD', 'LQRDC', 'WIND', 'WINDC', 'TOBD', 'TOBDC', 'VLQRD', 'VLQRDC', 'VWIND', 'VWINDC', 'LQRR','WINR','TOBR')
                    and iv.prtnum = pv.prtnum
                    and iv.invsts = 'AFS')]
|
[select count(prtnum) PrtWithRplcfgCnt
   from rplcfg
  where invsts = 'AFS']
|
[select count(prtnum) PrtNeedsTopOffCnt
 from rplcfg
where invsts = 'AFS'
  and minunt >= (select sum(untqty)
                   from inventory_view iv
                  where iv.stoloc = rplcfg.stoloc)]
|
publish data
  where ActivePrtCnt = @ActivePrtCnt
    and PrtWithRplcfgCnt = @PrtWithRplcfgCnt
    and PrtNeedsTopOffCnt = @PrtNeedsTopOffCnt