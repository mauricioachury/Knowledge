/* This script is used to move unnecessary amount of pallets into dummy pick zone 99999 to reduce
 * allocation performance.
 * list_pallet_flg: when this flag is 1, it will only list all inventory for the item order by expire date desc.
 * prtnum: The item to do the update.
 * unlock_pallet_cnt: How many pallets need to be kept as allocatable(not moved to dummy pick zone).
 * src_pick_zone: The reserve pick zone need to be looked at.
 * dummy_pick_zone: The dummy pick zone you want put the location into.
 */
publish data
 where list_pallet_flg = 1
   and prtnum = '695440'
   and unlock_pallet_cnt = 250
   and src_pick_zone = 10165
   and dummy_pick_zone = 10204
|
if (@list_pallet_flg = 1)
{
    /* List item, quantity and exire date*/
    [select im.old_expire_dte,
            im.prtnum,
            im.untqty,
            im.stoloc,
            lm.pck_zone_id
       from invsum im
       join locmst lm
         on im.stoloc = lm.stoloc
        and im.wh_id = lm.wh_id
      where prtnum = @prtnum
        and lm.wh_id = 'PRDC'
        and im.comqty = 0
      order by old_expire_dte desc]
}
else
{
    /* Put location from dummy pick zone back to expected pick zone first*/
    [update locmst
        set pck_zone_id = @src_pick_zone
      where pck_zone_id = @dummy_pick_zone] catch(-1403)
    |
    [select im.old_expire_dte,
            im.stoloc
       from invsum im
       join locmst lm
         on im.stoloc = lm.stoloc
        and im.wh_id = lm.wh_id
        and lm.pck_zone_id = @src_pick_zone
      where prtnum = @prtnum
        and lm.wh_id = 'PRDC'
        and im.comqty = 0
      order by old_expire_dte desc] >> res
    |
    /* Only move unnecessary number of pallets into dummy pick zone*/
    if (rowcount(@res) > @unlock_pallet_cnt)
    {
        publish top rows
         where count = rowcount(@res) - @unlock_pallet_cnt
           and res = @res
        |
        [update locmst
            set pck_zone_id = @dummy_pick_zone
          where stoloc = @stoloc
            and wh_id = 'PRDC']
    }
}; 