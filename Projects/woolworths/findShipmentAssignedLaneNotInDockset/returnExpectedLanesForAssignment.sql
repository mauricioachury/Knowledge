/* This script return stage lanes which is expected for the assignment passed.
 * 1. If the shipment for the assigment is allociated with dockset, then all
 *    stage lanes associated with the dockset are returned.
 * 2. Else we return all stage lanes which is avaialble.
 */
publish data
 where list_id = 'LST000000264101'
|
[select ship_id
   from pckwrk_view pv
  where pv.list_id = @list_id
    and rownum < 2]
|
[select distinct mov_zone_id,
        wh_id
   from pckmov pm
  where pm.rescod = @ship_id]
|
get expected dock doors for shipment
 where ship_id = @ship_id >> res
|
if (rowcount(@res) > 0)
{
    get prioritized lanes for dock doors
     where dckRes = @res
       and mov_zone_id = @mov_zone_id
       and wh_id = @wh_id >> stgres
    |
    sort result set
     where result_set = @stgres
       and sort_list = 'stgloc'
    |
    [select lm.stoloc,
            lm.rescod,
            lm.maxqvl,
            lm.curqvl,
            lm.pndqvl,
            lm.locsts,
            @lane_priority lane_priority
       from locmst lm
      where stoloc = @stgloc
        and wh_id = @wh_id]
}
else
{
    [select lm.stoloc,
            lm.rescod,
            lm.maxqvl,
            lm.curqvl,
            lm.pndqvl,
            lm.locsts
       from locmst lm
       join loc_typ lt
         on lm.loc_typ_id = lt.loc_typ_id
        and lm.wh_id = lt.wh_id
      where lt.stgflg = 1
        and lm.rescod is null
      order by stoloc]
}