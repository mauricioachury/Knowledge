publish data
 where list_id = 'LST000000185389'
   and from_dte = '2019-09-12'
   and to_dte = '2019-09-26'
|
[select list_id,
        count(distinct pv.last_pck_usr_id) usr_cnt
   from pckwrk_view pv
  where pv.pcksts = 'C'
    and pv.list_id is not null
    and to_char(pv.pckdte, 'yyyy-mm-dd') >= @from_dte
    and to_char(pv.pckdte, 'yyyy-mm-dd') <= @to_dte
    and @+list_id
    and @+last_pck_usr_id
  group by list_id
 having count(distinct pv.last_pck_usr_id) > 1]
|
[select pv.list_id,
        pv.last_pck_usr_id,
        uv.first_name || ',' || uv.last_name un,
        min(to_char(pv.pckdte, 'yyyy-mm-dd')) fpd,
        min(to_char(pv.pckdte, 'hh24:mi:ss')) fpt,
        min(list_seqnum) min_seqnum
   from pckwrk_view pv
   join users_view uv
     on pv.last_pck_usr_id = uv.usr_id
  where pv.list_id = @list_id
  group by pv.list_id,
        pv.last_pck_usr_id,
        uv.first_name,
        uv.last_name
  order by list_id,
        fpd,
        fpt]
|
[select @list_id list_id,
        @last_pck_usr_id "User ID",
        @un "User Name",
        @fpd "First Pick Date",
        @fpt "First Pick Time",
        srcloc "First Pick Location"
   from pckwrk_view pv
  where pv.list_id = @list_id
    and pv.last_pck_usr_id = @last_pck_usr_id
    and pv.list_seqnum = @min_seqnum]