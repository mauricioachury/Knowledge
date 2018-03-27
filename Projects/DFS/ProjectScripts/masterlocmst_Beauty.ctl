[select length('@stos@') stolen
   from dual]
|
if (@stolen = 7)
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
      where j = to_number(@i + @start)
    |
    [select decode(@prefix, 'AD', 19, 'AE', 19, 'AF', 16, 'AG',16, 'AH', 19, 'AI', 19, 'AJ', 16, 'AK', 16, 'AL', 19, 'AM', 19, 'AN', 16, 'AO', 16) levels from dual]
    |
    if (@levels = 19)
    {
        [select mod(@j, 13) pos, floor(@j / 13) bay from dual]
        |
        if (@pos <= 6)
        {
            publish data
              where verasc = 1
            |
            [select mod(@lvl, 2) sgn from dual]
            |
            if (@sgn = 1)
            {
                [select to_number('@bastrv@') + @bay * 1000 + (@lvl - 1) * 6 + @pos trvseq from dual]
            }
            else
            {
                [select to_number('@bastrv@') + @bay * 1000 + (@lvl - 1) * 6 + (6 - @pos + 1) trvseq from dual]
            }
        }
        else
        {
            publish data
              where verasc = 0
            |
            [select mod(@lvl, 2) sgn from dual]
            |
            if (@sgn = 1)
            {
                [select to_number('@bastrv@') + @bay * 1000 + 19 * 6 + (19 - @lvl) * 7 + @pos trvseq from dual]
            }
            else
            {
                [select to_number('@bastrv@') + @bay * 1000 + 19 * 6 + (19 - @lvl) * 7 + (13 - @pos + 1) trvseq from dual]
            }
        }
    }
    else if (@levels = 16)
    {
        if (to_number(@lvl) <= 3)
        {
            [select mod(@j, 6) pos, floor(@j / 6) bay from dual]
            |
            if (@pos <= 3)
            {
                publish data
                  where verasc = 1
                |
                [select mod(@lvl, 2) sgn from dual]
                |
                if (@sgn = 1)
                {
                    [select to_number('@bastrv@') + @bay * 1000 + (@lvl - 1) * 3 + @pos trvseq from dual]
                }
                else
                {
                    [select to_number('@bastrv@') + @bay * 1000 + (@lvl - 1) * 3 + (3 - @pos + 1) trvseq from dual]
                }
            }
            else
            {
                publish data
                  where verasc = 0
                |
                [select mod(@lvl, 2) sgn from dual]
                |
                if (@sgn = 1)
                {
                    [select to_number('@bastrv@') + @bay * 1000 + 13 * 13 + (3 - @lvl) * 6 + @pos trvseq from dual]
                }
                else
                {
                    [select to_number('@bastrv@') + @bay * 1000 + 13 * 13 + (3 - @lvl) * 6 + (6 - @pos + 1) trvseq from dual]
                }
            }
        }
        else
        {
            [select mod(@j, 13) pos, floor(@j / 13) bay from dual]
             |
             if (@pos <= 6)
             {
                 publish data
                   where verasc = 1
                 |
                 [select mod(@lvl, 2) sgn from dual]
                 |
                 if (@sgn = 1)
                 {
                     [select to_number('@bastrv@') + @bay * 1000 + (@lvl - 1) * 6 + @pos trvseq from dual]
                 }
                 else
                 {
                     [select to_number('@bastrv@') + @bay * 1000 + (@lvl - 1) * 6 + (6 - @pos + 1) trvseq from dual]
                 }
             }
             else
             {
                 publish data
                   where verasc = 0
                 |
                 [select mod(@lvl, 2) sgn from dual]
                 |
                 if (@sgn = 1)
                 {
                     [select to_number('@bastrv@') + @bay * 1000 + 16 * 6 + (16 - @lvl) * 7 + @pos trvseq from dual]
                 }
                 else
                 {
                     [select to_number('@bastrv@') + @bay * 1000 + 16 * 6 + (16 - @lvl) * 7 + (13 - @pos + 1) trvseq from dual]
                 }
             }
         }
    }
    |
    publish data
     where stoloc = @stoloc
       and trvseq = @trvseq
}
|
[ select count(*) row_count from locmst where
    stoloc = @stoloc and wh_id = '@wh_id@' ]
| if (@row_count > 0)
  {
       [ update locmst set trvseq = @trvseq
             where  stoloc = @stoloc and wh_id = '@wh_id@']
}
