publish data
 where upgrade_rate = 1
   and downgrade_rate = 0.05
|
[select prtnum,
        stoloc,
        maxunt,
        minunt
   from rplcfg
  where invsts = 'AFS'
  order by prtnum]
|
[select decode(arecod, 'TOBD', '2', 'LQRD', '2', 'WIND', '2', 'VLQRD', '2', 'VWIND', '2', 'TOBDC', '3', 'LQRDC', '3', 'WINDC', '3', 'VWINDC', '3', 'VLQRDC', '3', 'ERRROR') velzon,
        arecod
   from locmst l
  where l.stoloc = @stoloc]
|
if (substr(@stoloc, 1, 1) >= 'M' and substr(@stoloc, 1, 1) <= 'P' and substr(@stoloc, 2, 2) >= '01' and substr(@stoloc, 2, 2) <= '03')
{
    publish data
     where velzon = '4'
}
|
[select round(avg(shpqty)) avg_shpqty
   from tmp_sku_shpqty
  where prtnum = @prtnum
    and inv_attr_str1 = decode(@arecod, 'VLQRD', '1506', 'VLQRDC', '1506', 'VWIND', '1506', 'VWINDC', '1506', inv_attr_str1)]
|
if (@avg_shpqty >= @upgrade_rate * @maxunt and (@velzon = '2' or @velzon = '3' or @velzon = '4'))
{
    publish data
     where prtnum = @prtnum
       and stoloc = @stoloc
       and arecod = @arecod
       and maxunt = @maxunt
       and avgshpqty = @avg_shpqty
       and loctyp = @velzon
       and action = 'Upgrade'
}
else if (@avg_shpqty <= @downgrade_rate * @maxunt and (@velzon = '1' or @velzon = '2' or @velzon = '3'))
{
    publish data
     where prtnum = @prtnum
       and stoloc = @stoloc
       and arecod = @arecod
       and maxunt = @maxunt
       and avgshpqty = @avg_shpqty
       and loctyp = @velzon
       and action = 'Downgrade'
}