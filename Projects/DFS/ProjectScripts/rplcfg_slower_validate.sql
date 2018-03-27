[select lm.stoloc,
        lm.wh_id
   from locmst lm
  where substr(lm.stoloc, 1, 1) >= 'M'
    and substr(lm.stoloc, 1, 1) <= 'P'
    and substr(lm.stoloc, 2, 2) >= '01'
    and substr(lm.stoloc, 2, 2) <= '03'
    and lm.arecod in (select arecod from aremst where bldg_id = 'Greenwich' and wh_id = 'SGDC')
  group by lm.stoloc, lm.wh_id]
|
[select prtnum,
        sum(untqty) maxunt,
        1 minunt
   from inventory_view iv
  where iv.stoloc = @stoloc
   group by iv.prtnum] catch(-1403) 
|
if (@? = -1403)
{
    [select @stoloc stoloc,
            nvl(@prtnum, 'NoPrtnum') prtnum,
            '1' error_type,
            'No inventory exists for location:' || @stoloc reason from dual]
}
else
{
    [select prtnum other_prtnum
       from rplcfg
      where stoloc = @stoloc
        and wh_id = 'SGDC'
        and prtnum <> @prtnum
        and prt_client_id = '----'
        and rownum < 2
    ] catch(-1403)
    |
    if (@? = 0)
    {
        [select @stoloc stoloc,
         nvl(@prtnum, 'NoPrtnum') prtnum,
         '2' error_type,
         'Location:' || @stoloc || ' assigned to different SKU:' || @other_prtnum reason from dual]
    }
    else
    {
        [select distinct prtfam asg_prtfam
           from prtmst_view
          where prtnum = @prtnum
            and wh_id = 'SGDC']
        |
        [select arecod asg_arecod
          from locmst
         where stoloc = @stoloc
           and wh_id = 'SGDC']
        |
        if ((@asg_prtfam = 'Wine-Champ' and @asg_arecod not like '%WIND' and @asg_arecod not like '%WINDC') or
            (@asg_prtfam = 'Tobacco' and @asg_arecod != 'TOBD' and @asg_arecod != 'TOBDC') or
            (@asg_prtfam = 'Liquor' and @asg_arecod not like '%LQRD' and @asg_arecod not like '%LQRDC') or
            (@asg_prtfam = 'Beer' and @asg_arecod not like '%LQRD' and @asg_arecod not like '%LQRDC'))
        {
            [select @stoloc stoloc,
                    nvl(@prtnum, 'NoPrtnum') prtnum,
                    '3' error_type,
                   'Item family:' || @asg_prtfam || ' is incorrectly assigned to area:' || @asg_arecod || ' for location:' || @stoloc || ', prtnum:' || @prtnum reason from dual]
        }
        else
        {
            [select @stoloc stoloc,
                    @prtnum prtnum,
                    'OK' error_type,
                    'Location:' || @stoloc || ' can be assigned to SKU:' || @prtnum reason from dual]
        }
    }
}