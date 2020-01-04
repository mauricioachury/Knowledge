/* This script find pick or pick move allocated with lane which is not defined in
 * 'get prioritized lanes for dock doors' command.
 * This will cause ack assignment 'no lanes avaiale' issue.
 * Run first part of this command will tell you available lanes for the
 * shipment passed.
 */
publish data
 where ship_id = 'SID0046460'
|
[select distinct mov_zone_id,
        wh_id
   from pckmov pm
  where pm.rescod = @ship_id]
|
get expected dock doors for shipment
 where ship_id = @ship_id >> res
|
get prioritized lanes for dock doors
 where dckRes = @res
   and mov_zone_id = @mov_zone_id
   and wh_id = @wh_id >> lanes
|
convert column results to string
 where resultset = @lanes
   and colnam = 'stgloc'
   and separator = ','
|
convert list to in clause
 where string = @result_string
   and column_name = 'pv.dstloc'
|
publish data
 where pv_not_in_clause = 'not ' || @in_clause
|
convert list to in clause
 where string = @result_string
   and column_name = 'pm.stoloc'
|
publish data
 where pm_not_in_clause = 'not ' || @in_clause
|
[select pv.ship_id,
        pv.dstloc,
        pv.list_id,
        pv.wrkref,
        pm.rescod,
        pm.seqnum,
        pm.stoloc,
        pm.alcflg
   from pckwrk_view pv
   join pckmov pm
     on pv.cmbcod = pm.cmbcod
  where (@pv_not_in_clause:raw or @pm_not_in_clause:raw)
    and ship_id = @ship_id]