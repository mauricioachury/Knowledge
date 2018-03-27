[select length('@stos@') stolen
   from dual]
|
if (@stolen = 6)
{
    publish data
     where prefix = substr('@stos@', 1, 1)
       and lvl = substr('@stos@', 2, 2)
       and start = to_number(substr('@stos@', 4, 3))
       and end = to_number(substr('@stoe@', 4, 3))
}
else if (@stolen = 7)
{
    publish data
     where prefix = substr('@stos@', 1, 2)
       and lvl = substr('@stos@', 3, 2)
       and start = to_number(substr('@stos@', 5, 3))
       and end = to_number(substr('@stoe@', 5, 3))
}
|
do loop
 where count = @end - @start + 1
|
{
    [select @prefix || @lvl || lpad((@i + @start), 3, '0') stoloc
       from dual]
   |
    publish data
     where stoloc = @stoloc
       and wh_id = 'SGDC'
}
|
[ select count(*) row_count from locmst where
    stoloc = @stoloc and wh_id = @wh_id and arecod <> '@arecod@']
| if (@row_count > 0)
{
       [update locmst set arecod = '@arecod@'
             where  stoloc = @stoloc and wh_id = @wh_id]
       |
       [update invsum set arecod = '@arecod@'
             where stoloc = @stoloc and wh_id = @wh_id] catch(-1403)
       |
       [update pckwrk set srcare = '@arecod@'
           where srcloc = @stoloc and wh_id = @wh_id] catch(-1403)
}
