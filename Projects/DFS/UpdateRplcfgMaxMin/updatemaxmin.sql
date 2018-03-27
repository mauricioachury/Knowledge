/* Based on tmp_sku_rcvqty to get palqty,
 * Based on tmp_sku_shpqty to get daily shpqty.
 * update the rplcfg maxunt and minunt accordingly
 */
[delete
   from tmp_sku_rcvqty
  where 1 = 1];
[insert
   into tmp_sku_rcvqty select prtnum,
        trnqty,
        count(*) rcvcnt
   from tmp_dlytrn
  where fr_arecod = 'EXPR'
    and trndte > sysdate - 60
  group by prtnum,
        trnqty];
[delete
   from tmp_sku_shpqty
  where 1 = 1];
[insert
   into tmp_sku_shpqty select sum(pckqty),
        prtnum,
        to_char(pckdte, 'yyyy-mm-dd') pckdte
   from pckwrk
  where pcksts = 'C'
    and wrktyp = 'P'
    and pckdte > sysdate - 60
  group by prtnum,
        to_char(pckdte, 'yyyy-mm-dd')];
[select r.prtnum,
        r.stoloc,
        r.arecod
   from rplcfg r
  where not exists(select 'x'
                     from tmp_rplcfg_bak b
                    where b.stoloc = r.stoloc
                      and b.prtnum = r.prtnum)
  order by r.prtnum]
|
[select distinct velzon
   from tmp_loctype lt
  where lt.stoloc = @stoloc] catch(-1403)
|
if (@? = -1403)
{
    publish data
     where velzon = 'B'
}
|
[select max maxunt,
        min minunt
   from tmp_minmax
  where prtnum = @prtnum
    and stoloc = @stoloc] catch(-1403)
|
if (@? = -1403)
{
    [select rcvqty lpnqty
       from tmp_sku_rcvqty
      where prtnum = @prtnum
      order by rcvcnt desc,
            rcvqty desc] catch(-1403) >> res
    |
    if (@? = -1403)
    {
        publish data
         where stop_flg = 1
    }
    else
    {
        publish top rows
         where count = 1
           and res = @res
        |
        publish data
         where maxunt = @lpnqty
    }
}
|
if (@stop_flg != 1)
{
    [select decode(nvl(@velzon, 'B'), '1', 4, '2', 2, 1) * @maxunt maxunt
       from dual]
    |
    if (@velzon = '4' or @velzon = '3' or (substr(@stoloc, 1, 1) >= 'M' and substr(@stoloc, 1, 1) <= 'P' and substr(@stoloc, 2, 2) >= '01' and substr(@stoloc, 2, 2) <= '03'))
    {
        [select sum(untqty) invqty,
                max(untcas) invcas
           from inventory_view i
          where i.stoloc = @stoloc
            and i.prtnum = @prtnum]
        |
        if (@invqty is null)
        {
            publish data
             where stop_flg = 1
        }
        else
        {
            publish data
             where maxunt = @invqty
               and invcas = @invcas
        }
    }
    |
    if (@stop_flg != 1)
    {
        [select round(1.5*avg(shpqty)) shpqty
           from tmp_sku_shpqty
          where prtnum = @prtnum]
        |
        if (@shpqty is null)
        {
            publish data
             where stop_flg = 1
        }
        else
        {
            if (@shpqty > @maxunt)
            {
                publish data
                 where maxunt = @shpqty
                   and minunt = @shpqty
            }
            else
            {
                publish data
                 where maxunt = @maxunt
                   and minunt = @shpqty
            }
        }
        |
        if (@stop_flg != 1)
        {
            [update rplcfg
                set maxunt = @maxunt,
                    minunt = @minunt
              where prtnum = @prtnum
                and stoloc = @stoloc]
            |
            [update locmst
                set def_maxqvl = @maxunt,
                    maxqvl = @maxunt
              where stoloc = @stoloc]
        }
    }
};
[select 'x'
   from dual
  where 1 = 2]