[select lm.stoloc,
        lm.wh_id
   from locmst lm
  where substr(lm.stoloc, 1, 1) >= 'M'
    and substr(lm.stoloc, 1, 1) <= 'P'
    and substr(lm.stoloc, 2, 2) >= '01'
    and substr(lm.stoloc, 2, 2) <= '03'
    and lm.arecod in (select arecod from aremst where bldg_id = 'Greenwich' and wh_id = 'SGDC')
  union
   select distinct r.stoloc,
          r.wh_id
     from rplcfg r,
        inventory_view i
     where r.stoloc = i.stoloc
     and r.prtnum <> i.prtnum
     and r.invsts = 'AFS']
|
[select prtnum,
        sum(untqty) maxunt,
        max(untcas) minunt
   from inventory_view iv
  where iv.stoloc = @stoloc
   group by iv.prtnum] catch(-1403)
|
if (@? = -1403)
{
    [update locmst set useflg = 0
      where stoloc = @stoloc
        and wh_id = @wh_id]
}
else
{
    [select 'x'
       from rplcfg
      where stoloc = @stoloc
        and wh_id = 'SGDC'
        and prt_client_id = '----'] catch(-1403)
     |
     if (@? = 0)
     {
         [update locmst
             set asgflg = 0
          where stoloc = @stoloc
            and asgflg = 1] catch(-1403)
         |
         [delete
            from rplcfg
           where stoloc = @stoloc
          ] catch(-1403)
         |
         [delete
            from poldat
           where polcod = 'STORE-ASG-LOC-STS-AFS'
             and mod_usr_id = 'SAMNI'
             and rtstr1 = rtstr2
             and rtstr1 = @stoloc] catch(-1403)
         |
         [delete
            from poldat_hst
            where polcod = 'STORE-ASG-LOC-STS-AFS'
             and new_rtstr1 = new_rtstr2
             and new_rtstr1 = @stoloc
             and mod_usr_id = 'SAMNI'] catch(-1403)
         |
         if (@prtnum <> '')
         {
             [select minunt old_minunt,
                     maxunt old_maxunt
                from rplcfg
               where prtnum = @prtnum
                 and wh_id = 'SGDC'
                 and arecod in (select arecod
                                  from locmst
                                 where stoloc = @stoloc
                                   and wh_id = 'SGDC')] catch(-1403)
             |
             if (@? = 0)
             {
                 publish data
                   where minunt = @old_minunt
                     and maxunt = @old_maxunt
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
         and stoloc = @stoloc]
     |
     {
         create replenishment configuration
          WHERE wh_id = 'SGDC'
            AND prtnum = @prtnum
            AND prt_client_id = '----'
            AND stoloc = @stoloc
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
           where stoloc = @stoloc]
         ;
         [select stoloc polloc
            from rplcfg r
           where r.prtnum = @prtnum
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
                 and polval like '----|'||@prtnum||'%']
             |
             [update poldat
                 set mod_usr_id = 'SAMNI'
               where polcod = 'STORE-ASG-LOC-STS-AFS'
                 and polval like '----|'||@prtnum||'%']
         }
     }
}