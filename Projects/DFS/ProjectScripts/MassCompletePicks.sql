publish data
 where devcod = 'RDT099'
   and wh_id = 'SGDC'
|
[select wrkref,
        pckqty,
        appqty,
        srcloc
   from pckwrk
  where ship_id = 'SID0461294'
    and pcksts <> 'C'
    and pckqty > appqty]
|
{
    move inventory
     where wh_id = @wh_id
       and wrkref = @wrkref
       and srcqty = @pckqty - @appqty
       and srcloc = @srcloc
       and dstloc = @devcod;
}
|
[select distinct lodnum
   from inventory_view
  where stoloc = @devcod]
|
[select distinct stoloc,
        seqnum
   from invmov
  where lodnum in (select lodnum
                     from invsub
                    where lodnum = @lodnum
                   union
                   select subnum
                     from invsub
                    where lodnum = @lodnum
                   union
                   select dtlnum
                     from invdtl,
                          invsub
                    where invdtl.subnum = invsub.subnum
                      and invsub.lodnum = @lodnum)
  order by seqnum] catch(-1403)
|
move inventory
 where srclod = @lodnum
   and srcsub = ''
   and srcdtl = ''
   and wrkref = ''
   and wh_id = @wh_id
   and srcloc = @devcod
   and dstloc = @stoloc
   and dstlod = ''
   and dstsub = ''
   and actcod = 'TRN';
[select ' x '
   from dual
  where 1 = 2]