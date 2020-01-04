[select q.dstloc,
        max(q.reqnum) lst_reqnum
   from wrkque q
   join pckwrk_view pv
     on q.wrkref = pv.wrkref
  where q.oprcod in ('PIARPL', 'PRP')
    and q.effpri <= 15
  group by q.dstloc
  order by dstloc]
|
[select sum(pv.pckqty - pv.appqty) dr_pckqty
   from wrkque q
   join pckwrk_view pv
     on q.wrkref = pv.wrkref
    and q.wh_id = pv.wh_id
    and q.dstloc = @dstloc
    and q.effpri <= 15
    and q.reqnum <> @lst_reqnum]
|
[select im.untqty,
        nvl(pw.ack_pckqty, 0) ack_pckqty
   from invsum im
   left
   join (select sum(pv.pckqty - pv.appqty) ack_pckqty,
                pv.srcloc,
                pv.wh_id
           from wrkque q
           join pckwrk_view pv
             on q.list_id = pv.list_id
            and q.wh_id = pv.wh_id
          where q.wrksts = 'ACK'
            and pv.srcloc = @dstloc
          group by pv.srcloc,
                pv.wh_id) pw
     on im.stoloc = pw.srcloc
    and im.wh_id = pw.wh_id
  where stoloc = @dstloc]
|
if (@untqty + @dr_pckqty >= @ack_pckqty)
{
    [select pv.pckqty - pv.appqty dr_pckqty,
            q.effpri,
            q.reqnum,
            q.adddte,
            q.dstloc,
            @untqty available_qty,
            @ack_pckqty ack_pckqty
       from wrkque q
       join pckwrk_view pv
         on q.wrkref = pv.wrkref
        and q.wh_id = pv.wh_id
        and q.dstloc = @dstloc
        and q.effpri <= 15]
}