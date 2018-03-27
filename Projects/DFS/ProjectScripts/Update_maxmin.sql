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
   into tmp_sku_shpqty
   select sum(pckqty) shpqty,
   prtnum,
   inv_attr_str1,
   to_char(pckdte, 'yyyy-mm-dd') pckdte
from pckwrk
where pcksts = 'C'
and wrktyp = 'P'
and pckdte > sysdate - 60
and inv_attr_str1 is not null
group by prtnum,inv_attr_str1,
   to_char(pckdte, 'yyyy-mm-dd')];

[select r.prtnum,
        r.stoloc,
        r.arecod
   from rplcfg r
  order by r.prtnum]
|
[select decode(arecod, 'TOBD', '2', 'LQRD', '2', 'WIND', '2', 'VLQRD', '2', 'VWIND', '2', 'TOBDC', '3', 'LQRDC', '3', 'WINDC', '3', 'VWINDC', '3', 'VLQRDC', '3', 'ERRROR') velzon,
        decode(arecod, 'VLQRD', '1506', 'VWIND', '1506', 'VWINDC', '1506', 'VLQRDC', '1506', 'OTHERS') inv_attr_str1
   from locmst l
  where l.stoloc = @stoloc]
|
if (substr(@stoloc, 1, 1) >= 'M' and substr(@stoloc, 1, 1) <= 'P' and substr(@stoloc, 2, 2) >= '01' and substr(@stoloc, 2, 2) <= '03')
{
    publish data
     where velzon = '4'
}
|
[select rcvqty lpnqty
   from tmp_sku_rcvqty
  where prtnum = @prtnum
  order by rcvcnt desc,
        rcvqty desc] catch(-1403) >> res
|
if (@? = -1403)
{
    [select sum(untqty) lpnqty,
            max(untcas) invcas
       from inventory_view i,
            locmst l
       where i.stoloc = l.stoloc
        and i.prtnum = @prtnum
        and l.arecod in (select arecod from aremst where bldg_id = 'Greenwich')
        and untcas < 10000
       group by l.stoloc
       order by lpnqty desc] catch(-1403) >> res
       |
       if (@? = 0)
       {
            publish top rows
              where count = 1
                and res = @res
            |
            publish data
              where maxunt = @lpnqty
       }
       else
       {
            publish data
             where stop_flg = 1
       }
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
|
if (@stop_flg != 1)
{
    if (substr(@stoloc, 2,2) = '02')
    {
        publish data
          where maxunt = @maxunt
    }
    else
    {
        [select decode(nvl(@velzon, 'B'), '1', 4, '2', 2, 1) * @maxunt maxunt
           from dual]
    }
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
            [select max(untcas) invcas,
                    10 * max(untcas) maxunt
               from inventory_view i,
                    locmst l
              where i.stoloc = l.stoloc
                and i.prtnum = @prtnum
                and l.arecod in (select arecod from aremst where bldg_id = 'Greenwich')
                and untcas < 10000
              group by l.stoloc] catch(-1403) >> res
            |
            if (@? = 0)
            {
                publish top rows
                  where count = 1
                    and res = @res
            }
            else
            {
                publish data
                 where stop_flg = 1
            }
        }
        else
        {
            publish data
             where maxunt = @invqty
               and invcas = @invcas
        }
    }
    else
    {
        [select max(untcas) invcas
           from inventory_view i
          where i.stoloc = @stoloc
            and i.prtnum = @prtnum]
        |
        if (@invcas is null)
        {
            [select max(untcas) invcas
               from inventory_view i,
                    locmst l
              where i.stoloc = l.stoloc
                and i.prtnum = @prtnum
                and l.arecod in (select arecod from aremst where bldg_id = 'Greenwich')
                and untcas < 10000] catch(-1403) >> res
             |
             if (@? = 0)
             {
                 publish top rows
                 where count = 1
                   and res = @res
             }
             else
             {
                 publish data
                   where stop_flg = 1
             }
        }
    }
    |
    if (@stop_flg != 1)
    {
        if (@inv_attr_str1 = '1506')
        {
        [select round(1.5*avg(shpqty)) shpqty
           from tmp_sku_shpqty
          where prtnum = @prtnum
            and inv_attr_str1 = '1506']
        }
        else
        {
            [select round(1.5*avg(shpqty)) shpqty
               from tmp_sku_shpqty
              where prtnum = @prtnum
                and inv_attr_str1 <> '1506']
        }
        |
        if (@shpqty is null)
        {
            publish data
             where stop_flg = 1
        }
        else
        {
            if (@shpqty > 0 and @invcas > 0)
            {
                [select ceil(@shpqty / @invcas) * @invcas shpqty
                   from dual]
            }
            |
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
            if (@invcas >0 and @maxunt < 10 * @invcas)
            {
                publish data
                  where maxunt = 10 * @invcas
            }
            |
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
[update rplcfg
    set maxunt = (select sum(untqty)
                    from inventory_view iv
                   where iv.stoloc = rplcfg.stoloc)
  where maxunt < (select sum(untqty)
                    from inventory_view iv
                   where iv.stoloc = rplcfg.stoloc)]