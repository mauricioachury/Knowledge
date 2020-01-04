/* The following values are used to help make some adjustements to what the job is doing
 * least_important: Defines the value of the least important work that the job picks up. Work that isn't associated with a shipment will be set to this value
 * most_important: Defines the value of the most important work. Work will not escalate higher than this.
 * increment_by: Defines how much to increment the priority by as we group over the ship dates. 
 * increment_limit: We will count up from the most_important value by the increment_limit until we hit the increment_limit. 
 * ignore_below: We will ingore any existing work that has been escalated to a value equal to or lower than this number
 */
list warehouses
|
[select min(baspri) as least_important
   from wrkopr
  where oprcod in ('PRP', 'PIARPL')
    and wh_id_tmpl = @wh_id]
|
publish data
 where most_important = 20
   and increment_by = 2
   and increment_limit = 50
   and ignore_below = 15
|
[select details.arecod,
        details.reqnum,
        details.oprcod,
        details.wrksts,
        details.replen_destination,
        details.seal_date,
        details.order_pick_count,
        details.qty_needed qty_needed,
        details.qty_onhand qty_onhand,
        details.qty_short,
        details.effpri,
        -- If there is enough in the location to satisfy ALL picks, set the
        -- priority to 55.

        CASE WHEN (details.qty_short <= 0) THEN @least_important
             ELSE LEAST(((@most_important - @increment_by) + @increment_by *(DENSE_RANK() OVER(partition by arecod order by seal_date))), @increment_limit)
        END new_priority
   from(select substr(lm.arecod, 1, 1) arecod,
            replen_work.reqnum,
            replen_work.oprcod,
            replen_work.effpri,
            replen_work.dstloc replen_destination,
            replen_work.wrksts,
            min(nvl(shipment.early_shpdte, (sysdate + 30))) seal_date,
            count(distinct p_pick.wrkref) order_pick_count,
            (sum(nvl(p_pick.dtl_pckqty, 0)) - sum(nvl(p_pick.dtl_appqty, 0))) qty_needed,
            nvl(invsum.untqty, 0) qty_onhand,
            (sum(nvl(p_pick.dtl_pckqty, 0)) - sum(nvl(p_pick.dtl_appqty, 0))) - nvl(invsum.untqty, 0) qty_short
       from wrkque replen_work
       join locmst lm
         on replen_work.srcloc = lm.stoloc
        and replen_work.wh_id = lm.wh_id
            -- Changed the join to pckwrk_view into a subqery so we could weed out the completed picks in
            -- advance. Now locations with no picks and locations with picks that have been completed will
            -- appear to be the same for the rest of the query.

       left
       join (select wrkref,
                    srcloc,
                    wh_id,
                    ship_id,
                    dtl_pckqty,
                    dtl_appqty,
                    pckqty,
                    appqty
               from pckwrk_view
              where dtl_appqty < dtl_pckqty
                and pcksts != 'C') p_pick
         on replen_work.dstloc = p_pick.srcloc
        and replen_work.wh_id = p_pick.wh_id
       left
       join shipment
         on p_pick.ship_id = shipment.ship_id
       left
       join invsum
         on replen_work.dstloc = invsum.stoloc
        and replen_work.wh_id = invsum.wh_id
      where replen_work.wrksts in ('LOCK', 'PEND')
        and replen_work.effpri > @ignore_below
        and replen_work.oprcod in ('PRP', 'PIARPL')
     -- Setting the default value  for pckqty to 1 here to ensure
     -- we don't filter the row when there aren't any order picks at the 
     -- destination. The select will still show a 0 for qty_needed, so 
     -- we can set the priority to 55 in this scenario.

        and nvl(p_pick.dtl_appqty, 0) < nvl(p_pick.dtl_pckqty, 1)
      group by substr(lm.arecod, 1, 1),
                replen_work.reqnum,
                replen_work.oprcod,
                replen_work.effpri,
                replen_work.dstloc,
                invsum.untqty,
                replen_work.wrksts) details
  order by new_priority,
        replen_destination]
|
if(@effpri > @new_priority)
{
    [update wrkque
        set effpri = @new_priority,
            lstescdte = sysdate
      where reqnum = @reqnum
    ]
    |
    [select ph.prtnum,
            ph.pckqty,
            ph.wrkref,
            q.effpri new_effpri,
            q.oprcod,
            q.srcloc frstol,
            q.dstloc tostol
      from pckwrk_hdr ph
      join wrkque q
        on ph.wrkref = q.wrkref
       and ph.wh_id = q.wh_id
       and q.reqnum = @reqnum] catch(-1403)
    |
    if (@? = 0)
    {
        write daily transaction log
        where actcod = 'RPLPRIBUMP'
          and fr_value = @reqnum || ' for ' || @wrkref || ' with ' || @oprcod || ' escalating with effpri:' || @effpri || ' by seal time:' || @seal_date
          and to_value = @reqnum || ' for ' || @wrkref || ' with ' || @oprcod || ' to effpri:' || @new_effpri
          and frstol = @frstol
          and tostol = @tostol
          and prtnum = @prtnum
          and trnqty = @pckqty
          and wh_id = @wh_id
     }
}
