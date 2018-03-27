publish data
 where blk = 'L'
|
[select min(substr(blk, 1, 1)) sr,
        bastrv
   from tmp_rackpos
  where substr(blk, 2, 1) = @blk
  group by bastrv
  order by sr]
|
[select decode(@sr, 'A', 'dsc', 'E', 'dsc', 'I', 'dsc', 'M', 'dsc', 'C', 'asc', 'G', 'asc', 'K', 'asc', 'O', 'asc') srt
   from dual]
|
[select @sr sr,
        @srt srt,
        tmp_rackpos.*
   from tmp_rackpos
  where bastrv = @bastrv
  order by blk]