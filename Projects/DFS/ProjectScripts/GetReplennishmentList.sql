[select stoloc
   from locmst
  where pckflg = 0
    and arecod in ('TOBR', 'LQRR', 'WINR')
    and not exists(select 'x'
                     from rplwrk
                    where rplwrk.prtnum in (select prtnum
                                              from inventory_view iv
                                             where iv.stoloc = locmst.stoloc))] catch(-1403)
|
if (@? = 0)
{
    [update locmst
      set pckflg = 1
    where stoloc = @stoloc]
};

[delete
 from invsum
where not exists(select 'x'
                   from inventory_view iv
                  where iv.stoloc = invsum.stoloc
                    and iv.prtnum = invsum.prtnum)
  and not exists(select 'x'
                   from invmov
                  where invmov.stoloc = invsum.stoloc)
  and not exists(select 'x'
                   from pckwrk
                  where pckwrk.dstloc = invsum.stoloc)] catch(-1403);

[update invsum set comqty = 0 where comqty < 0] catch(-1403);

[select *
 from locmst
where arecod in ('LQRD', 'LQRDC', 'VLQRD', 'VLQRDC', 'WIND', 'WINDC', 'VWIND', 'VWINDC', 'TOBD', 'TOBDC', 'HOTPICK')
  and pndqvl > 0
  and not exists(select 'x'
                   from pckwrk
                  where dstloc = locmst.stoloc)
  and not exists(select 'x'
                   from invmov
                  where stoloc = locmst.stoloc)
  and not exists(select 'x'
                   from pckmov
                  where stoloc = locmst.stoloc)] catch(-1403)
|
if (@? = 0)
{
    [update locmst
        set pndqvl = 0
      where stoloc = @stoloc]
};

[select stoloc,
        prtnum,
        pndqty
   from invsum
  where arecod in ('LQRD', 'LQRDC', 'VLQRD', 'VLQRDC', 'WIND', 'WINDC', 'VWIND', 'VWINDC', 'TOBD', 'TOBDC', 'HOTPICK')
    and pndqty < 0] catch(-1403)
|
if (@? = 0)
{
    [update invsum
        set pndqty = 0
      where stoloc = @stoloc
        and prtnum = @prtnum]
};

[select prtnum,
        srcloc,
        count('x') cnt,
        sum(pckqty) tot_pckqty,
        min(cmbcod) min_cmbcod
   from pckwrk
  where wrktyp = 'E'
    and lodlvl = 'S'
    and pckqty > appqty
    and not exists(select 'x'
                  from wrkque q
                 where q.wrkref = pckwrk.wrkref
                   and q.wrksts = 'ACK')
group by prtnum, srcloc
having (count('x') > 1)] catch(-1403)
|
if (@? = 0)
{
[update pckwrk
 set pckqty = @tot_pckqty
where cmbcod = @min_cmbcod]
|
[delete
from wrkque
where wrkref in (select wrkref
                  from pckwrk
                 where wrktyp = 'E'
                   and srcloc = @srcloc
                   and prtnum = @prtnum
                   and cmbcod <> @min_cmbcod)] catch(-1403)
|
[delete
   from pckmov
  where cmbcod in (select cmbcod
                     from pckwrk
                    where wrktyp ='E'
                      and srcloc = @srcloc
                      and prtnum = @prtnum )
    and cmbcod <> @min_cmbcod]
|
[delete
from pckwrk
where wrktyp = 'E'
 and srcloc = @srcloc
 and prtnum = @prtnum
 and cmbcod <> @min_cmbcod]
};

[select distinct p.prtnum,
        p.lodlvl,
        p.pcksts,
        p.adddte,
        p.srcloc,
        d.lngdsc,
        p.dstare,
        p.dstloc,
        p.pckqty,
        p.wrkref
   from pckwrk p,
        prtdsc d
  where wrktyp = 'E'
    and d.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
    and d.colval like p.prtnum || '|%----']
|
[select distinct o.stcust
   from rplwrk r,
        ord o
  where r.ordnum = o.ordnum
    and r.wh_id = o.wh_id
    and r.prtnum = @prtnum] catch(-1403) >> res
|
if (@? = 0)
{
    [update invsum
        set comqty = 0
      where stoloc = @srcloc] catch(-1403)
    |
    [update locmst
        set pckflg = 0
      where stoloc = @srcloc]
    |
    convert column results to string
     where colnam = 'stcust'
       and res = @res
       and separator = ','
    |
    publish data
     where prtnum = @prtnum
       and description = @lngdsc
       and srcloc = @srcloc
       and dstare = @dstare
       and dstloc = @dstloc
       and stcust = @result_string
}
else
{
    cancel pick
     where wrkref = @wrkref
       and wh_id = @wh_id
    |
    [update locmst
        set pckflg = 1
      where stoloc = @srcloc]
    |
    [select loccod from aremst where arecod = @dstare]
    |
    if (@loccod = 'P')
    {
        [update locmst
            set pndqvl = decode(sign(pndqvl - 1), 1, pndqvl - 1, 0)
          where stoloc = @dstloc]
    }
    else
    {
        [update locmst
            set pndqvl = decode(sign(pndqvl - @pckqty) , 1, pndqvl - @pckqty, 0)
          where stoloc = @dstloc]
    }
}
