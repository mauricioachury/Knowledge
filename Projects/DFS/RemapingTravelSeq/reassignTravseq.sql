publish data
 where prefix = 'P'
   and base_start = 1
   and base_end = 105
   and top_start=1
   and top_end = 35
   and dsc = 0
|

    [select min(to_number(trvseq)) minseq,
        max(to_number(trvseq)) maxseq
   from locmst
  where stoloc like @prefix || '01%'
    and to_number(substr(stoloc, 4, 3)) >= @base_start
    and to_number(substr(stoloc, 4, 3)) <= @base_end]
|
publish data
 where maxloc = @top_end - @top_start + 1
|
do loop
 where count = 4
|
publish data
 where lvl = @i + 4
|
do loop
 where count = @maxloc
|
if (@dsc = 1)
{
    publish data
     where pos = (@maxloc - @i - 1) + @top_start
}
else
{
    publish data
     where pos = @i + @top_start
}
|
if (@pos < 100)
{
    [select @prefix || '0' || @lvl || lpad(@pos, 3, '0') stoloc from dual]
}
else
{
    publish data
     where stoloc = @prefix || '0' || @lvl || @pos
}
|
[select lpad(round((@i+1) * 1.0 / @maxloc *(@maxseq - @minseq) + @minseq), 7, '0') trvseq,
        @stoloc stoloc
   from dual]
|
[update locmst
    set trvseq = @trvseq
  where stoloc = @stoloc] catch(-1403)