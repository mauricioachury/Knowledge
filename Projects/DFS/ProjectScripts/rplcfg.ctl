[select 'x'
   from rplcfg
  where stoloc = '@stoloc@'
    and wh_id = 'SGDC'
    and prtnum <> '@prtnum@'
    and prt_client_id = '----'
    and rownum < 2
] catch(-1403)
|
if (@? = 0)
{
    [select 'failed of check' from dual where 1=2]
}
|
[select distinct prtfam asg_prtfam
   from prtmst_view
  where prtnum = '@prtnum@'
    and wh_id = 'SGDC']
|
[select arecod asg_arecod
  from locmst
 where stoloc = '@stoloc@'
   and wh_id = 'SGDC']
|
if ((@asg_prtfam = 'Wine-Champ' and @asg_arecod != 'WIND' and @asg_arecod != 'WINDC') or
    (@asg_prtfam = 'Tobacco' and @asg_arecod != 'TOBD' and @asg_arecod != 'TOBDC') or
    (@asg_prtfam = 'Liquor' and @asg_arecod != 'LQRD' and @asg_arecod != 'LQRDC') or
    (@asg_prtfam = 'Beer' and @asg_arecod != 'LQRD' and @asg_arecod != 'LQRDC'))
{
    [select 'Item family:' || @asg_prtfam || ' is incorrectly assigned to area:' || @asg_arecod from dual where 1=2 ] catch(-1403)
}
|
if ('@maxunt@' = '' or '@minunt@' = '')
{
    [select 'maxunt:' || '@maxunt@' || ' or minunt:' || '@minunt@' || ' is null' from dual where 1=2]
}
|
[select length('@stoloc@') stolen
 from dual]
|
if (@stolen = 6)
{
  publish data
   where prefix = substr('@stoloc@', 1, 1)
     and lvl = substr('@stoloc@', 2, 2)
}
else if (@stolen = 7)
{
  publish data
   where prefix = substr('@stoloc@', 1, 2)
     and lvl = substr('@stoloc@', 3, 2)
}
|
/*Do not load slow movers, located at row MNOP, level 1 to 3.*/
if (1 = 1 and !((@prefix = 'M' or @prefix = 'N' or @prefix = 'O' or @prefix = 'P') and (@lvl = '01' or @lvl = '02' or @lvl = '03')))
{
   [select 'x'
      from rplcfg
     where stoloc = '@stoloc@'
       and wh_id = 'SGDC'
       and prtnum = '@prtnum@'
       and prt_client_id = '----'] catch(-1403)
    |
    if (@? = 0)
    {
        [update locmst
            set asgflg = 0
         where stoloc = '@stoloc@'
           and asgflg = 1] catch(-1403)
        |
        [delete
           from rplcfg
          where stoloc = '@stoloc@'
         ] catch(-1403)
        |
        [delete
           from poldat
          where polcod = 'STORE-ASG-LOC-STS-AFS'
            and mod_usr_id = 'SAMNI'
            and rtstr1 = rtstr2
            and rtstr1 = '@stoloc@'] catch(-1403)
        |
        [delete
           from poldat_hst
           where polcod = 'STORE-ASG-LOC-STS-AFS'
            and new_rtstr1 = new_rtstr2
            and new_rtstr1 = '@stoloc@'
            and mod_usr_id = 'SAMNI'] catch(-1403)
    }
    |
    [update locmst
        set maxqvl = '@maxunt@',
            def_maxqvl = '@maxunt@',
            repflg = 1,
            useflg = 1
      where wh_id = 'SGDC'
        and stoloc = '@stoloc@']
    |
    {
        create replenishment configuration
         WHERE wh_id = 'SGDC'
           AND prtnum = '@prtnum@'
           AND prt_client_id = '----'
           AND stoloc = '@stoloc@'
           AND invsts = 'AFS'
           AND pctflg = '0'
           AND maxunt = '@maxunt@'
           AND minunt = '@minunt@'
           AND maxloc = '1'
           AND inc_pct_flg = '1'
           AND inc_unt = '0'
           AND rls_pct = '100'
        |
        [update rplcfg
            set mod_usr_id = 'SAMNI'
          where stoloc = '@stoloc@']
        ;
        [select stoloc polloc
           from rplcfg r
          where r.prtnum = '@prtnum@'
            and r.prt_client_id = '----'
            and r.wh_id = 'SGDC'
            and r.stoloc is not null
            and not exists(select 'x'
                             from poldat_view pv
                            where pv.polcod = 'STORE-ASG-LOC-STS-AFS'
                              and pv.polvar = 'prtnum'
                              and polval = '----' || '|' || '@prtnum@'
                              and rtstr1 = r.stoloc
                              and rtstr1 = rtstr2
                              and rownum < 2)] catch(-1403)
        |
        if (@? = 0)
        {
            create assigned location policy
             where prtnum = '@prtnum@'
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
                and polval like '----|@prtnum@%']
            |
            [update poldat
                set mod_usr_id = 'SAMNI'
              where polcod = 'STORE-ASG-LOC-STS-AFS'
                and polval like '----|@prtnum@%']
        }
    }
    |
    commit
}