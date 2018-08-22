publish data
 where start_dt = '2018-06-10 00:00'
   and end_dt = '2018-06-18 24:00'
   and by_day_flg = 1
|
if (@by_day_flg = 1)
{
    remote('http://ncdwwmsasp0004:49000/service')
    {
        [select sum(asset_qty),
                to_char(dispatch_dte, 'yyyy-mm-dd') dt
           from uc_stop_assets p,
                stop s,
                car_move c,
                trlr t
          where p.stop_id = s.stop_id
            and s.car_move_id = c.car_move_id
            and c.trlr_id = t.trlr_id
            and p.asset_typ not in ('DC', 'OS')
            and to_char(dispatch_dte, 'yyyy-mm-dd hh24:mi:ss') >= @start_dt
            and to_char(dispatch_dte, 'yyyy-mm-dd hh24:mi:ss') <= @end_dt
          group by to_char(dispatch_dte, 'yyyy-mm-dd')
          order by to_char(dispatch_dte, 'yyyy-mm-dd')] catch(-1403)
    } &
    [select sum(asset_qty),
            to_char(dispatch_dte, 'yyyy-mm-dd') dt
       from uc_stop_assets p,
            stop s,
            car_move c,
            trlr t
      where p.stop_id = s.stop_id
        and s.car_move_id = c.car_move_id
        and c.trlr_id = t.trlr_id
        and p.asset_typ not in ('DC', 'OS')
        and to_char(dispatch_dte, 'yyyy-mm-dd hh24:mi:ss') >= @start_dt
        and to_char(dispatch_dte, 'yyyy-mm-dd hh24:mi:ss') <= @end_dt
      group by to_char(dispatch_dte, 'yyyy-mm-dd')
      order by to_char(dispatch_dte, 'yyyy-mm-dd')] catch(-1403)
}
else
{
    remote('http://ncdwwmsasp0004:49000/service')
    {
        [select sum(asset_qty)
           from uc_stop_assets p,
                stop s,
                car_move c,
                trlr t
          where p.stop_id = s.stop_id
            and s.car_move_id = c.car_move_id
            and c.trlr_id = t.trlr_id
            and p.asset_typ not in ('DC', 'OS')
            and to_char(dispatch_dte, 'yyyy-mm-dd hh24:mi:ss') >= @start_dt
            and to_char(dispatch_dte, 'yyyy-mm-dd hh24:mi:ss') <= @end_dt]
    }
    |
    [select nvl(@cnt, 0) + nvl(sum(asset_qty),0) cnt
       from uc_stop_assets p,
            stop s,
            car_move c,
            trlr t
      where p.stop_id = s.stop_id
        and s.car_move_id = c.car_move_id
        and c.trlr_id = t.trlr_id
        and p.asset_typ not in ('DC', 'OS')
        and to_char(dispatch_dte, 'yyyy-mm-dd hh24:mi:ss') >= @start_dt
        and to_char(dispatch_dte, 'yyyy-mm-dd hh24:mi:ss') <= @end_dt]
}
