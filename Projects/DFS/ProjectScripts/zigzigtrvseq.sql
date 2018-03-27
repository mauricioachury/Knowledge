publish data
 where side = 'L' &
publish data
 where side = 'M' &
publish data
 where side = 'R' &
publish data
 where side = 'X'
|
[select substr(blk, 1, 1) sr,
        bastrv
   from tmp_rackpos
  where substr(blk, 2, 1) = @side
  order by sr]
|
[select decode(@sr, 'A', 'dsc', 'B', 'dsc', 'E', 'dsc', 'F', 'dsc', 'I', 'dsc', 'J', 'dsc', 'M', 'dsc', 'N', 'dsc', 'C', 'asc', 'D', 'asc', 'G', 'asc', 'H', 'asc', 'K', 'asc', 'L', 'asc', 'O', 'asc', 'P', 'asc') srt
   from dual]
|
[select max(highbtm) max_bh,
        max(hightop) max_th
   from tmp_rackpos
  where bastrv = @bastrv]
|
[select @sr sr,
        @srt srt,
        @max_bh max_bh,
        @max_th max_th,
        tmp_rackpos.*
   from tmp_rackpos
  where bastrv = @bastrv
    and substr(blk, 1, 1) = @sr
  order by blk]
|
if (@max_bh > @max_th)
{
    publish data
     where max_h = @max_bh
}
else
{
    publish data
     where max_h = @max_th
}
|
do loop
 where count = 7
|
if (@i = 0 or (@sr >= 'M' and @sr <= 'P' and @i <= 2))
{
    [select stoloc
       from locmst
      where stoloc like @sr || '0' || (@i + 1) || '%'
        and to_number(substr(stoloc, 4, 3)) <= @highbtm
        and to_number(substr(stoloc, 4, 3)) > nvl((select highbtm
                                                     from tmp_rackpos
                                                    where blk = @sr || decode(@side, 'M', 'L', 'R', 'M', 'X', 'R')), 0)
      order by stoloc] catch(-1403)
}
else
{
    [select stoloc
       from locmst
      where stoloc like @sr || '0' || (@i + 1) || '%'
        and to_number(substr(stoloc, 4, 3)) <= @hightop
        and to_number(substr(stoloc, 4, 3)) > nvl((select hightop
                                                     from tmp_rackpos
                                                    where blk = @sr || decode(@side, 'M', 'L', 'R', 'M', 'X', 'R')), 0)
      order by stoloc] catch(-1403)
}
|
if (@? = 0)
{
    if (@srt = 'dsc')
    {
        if (@i = 0 or (@sr >= 'M' and @sr <= 'P' and @i <= 2))
        {
            publish data
             where lowbtm = 1
            |
            [select to_number(substr(@stoloc, 4, 3)) idx
               from dual]
            |
            [select round((@highbtm - @lowbtm + 1 - @idx + 1) / (@highbtm - @lowbtm + 1) * @max_h) trvseq
               from dual]
            |
            [select lpad(@bastrv + @trvseq, 7, '0') trvseq
               from dual]
            |
            publish data
             where trvseq = @trvseq
               and stoloc = @stoloc
               and side = @side
        }
        else
        {
            publish data
             where lowtop = 1
            |
            [select to_number(substr(@stoloc, 4, 3)) idx
               from dual]
            |
            [select round((@hightop - @lowtop + 1 - @idx + 1) / (@hightop - @lowtop + 1) * @max_h) trvseq
               from dual]
            |
            [select lpad(@bastrv + @trvseq, 7, '0') trvseq
               from dual]
            |
            publish data
             where trvseq = @trvseq
               and stoloc = @stoloc
               and side = @side
        }
    }
    else
    {
        if (@i = 0 or (@sr >= 'M' and @sr <= 'P' and @i <= 2))
        {
            publish data
             where lowbtm = 1
            |
            [select to_number(substr(@stoloc, 4, 3)) idx
               from dual]
            |
            [select round(@idx / (@highbtm - @lowbtm + 1) * @max_h) trvseq
               from dual]
            |
            [select lpad(@bastrv + @trvseq, 7, '0') trvseq
               from dual]
            |
            publish data
             where trvseq = @trvseq
               and stoloc = @stoloc
               and side = @side
        }
        else
        {
            publish data
             where lowtop = 1
            |
            [select to_number(substr(@stoloc, 4, 3)) idx
               from dual]
            |
            [select round(@idx / (@hightop - @lowtop + 1) * @max_h) trvseq
               from dual]
            |
            [select lpad(@bastrv + @trvseq, 7, '0') trvseq
               from dual]
            |
            publish data
             where trvseq = @trvseq
               and stoloc = @stoloc
               and side = @side
        }
    }
}