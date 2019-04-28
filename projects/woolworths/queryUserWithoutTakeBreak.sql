publish data
 where start_dt = '2018-06-08 00:00'
   and end_dt = '2018-06-08 24:00'
|
[select ist.usr_id,
        uv.last_name || ',' || uv.first_name as user_name,
        to_char(ist.start_time, 'dd-mm-yyyy') query_date,
        ist.start_time
   from kvi_summary ist
   join users_view uv
     on ist.usr_id = uv.usr_id
  where ist.jobcodeid = 'ISTART'
    and to_char(ist.start_time, 'yyyy-mm-dd hh24:mi') >= @start_dt
    and to_char(ist.start_time, 'yyyy-mm-dd hh24:mi') <= @end_dt
  order by usr_id]
|
/* If no first 'BREAK' record exists and it's more than 5 hours from begin */
[select 'x'
   from dual
  where not exists(select 'x'
                     from kvi_adjustments k,
                          jobcode j,
                          kvi_summary a
                    where k.jobcodeintid = j.jobcodeintid
                      and k.kvisummaryintid = a.kvisummaryintid
                      and j.jobcodeid in ('BREAK')
                      and a.status in ('C', 'A')
                      and a.usr_id = @usr_id
                      and k.adj_start_time > to_date(@start_time)
                      and to_char(k.adj_start_time, 'yyyy-mm-dd') = to_char(to_date(@start_time), 'yyyy-mm-dd'))
    and sysdate > to_date(@start_time) + 5 / 24] catch(-1403)
|
if (@? = 0)
{
    publish data
     where no_fst_brk_flg = 1
}
|
/* If no first 'LUNCH' record exists and it's more than 6 hours from begin */
[select 'x'
   from dual
  where not exists(select 'x'
                     from kvi_adjustments k,
                          jobcode j,
                          kvi_summary a
                    where k.jobcodeintid = j.jobcodeintid
                      and k.kvisummaryintid = a.kvisummaryintid
                      and j.jobcodeid in ('LUNCH')
                      and a.status in ('C', 'A')
                      and a.usr_id = @usr_id
                      and k.adj_start_time > to_date(@start_time)
                      and to_char(k.adj_start_time, 'yyyy-mm-dd') = to_char(to_date(@start_time), 'yyyy-mm-dd'))
    and sysdate > to_date(@start_time) + 6 / 24] catch(-1403)
|
if (@? = 0)
{
    publish data
     where no_lch_brk_flg = 1
}
|
/* If no first 'OVRTBREAK' record exists and it's more than 9 hours from begin */
[select 'x'
   from dual
  where not exists(select 'x'
                     from kvi_adjustments k,
                          jobcode j,
                          kvi_summary a
                    where k.jobcodeintid = j.jobcodeintid
                      and k.kvisummaryintid = a.kvisummaryintid
                      and j.jobcodeid in ('OVRTBREAK')
                      and a.status in ('C', 'A')
                      and a.usr_id = @usr_id
                      and k.adj_start_time > to_date(@start_time)
                      and to_char(k.adj_start_time, 'yyyy-mm-dd') = to_char(to_date(@start_time), 'yyyy-mm-dd'))
    and sysdate > to_date(@start_time) + 9 / 24] catch(-1403)
|
if (@? = 0)
{
    publish data
     where no_snd_brk_flg = 1
}
|
[select @usr_id usr_id,
        @user_name user_name,
        @query_date query_date,
        to_char(to_date(@start_time), 'hh24:mi') begin_time,
        to_char(sysdate, 'hh24:mi') current_time,
        round((sysdate - to_date(@start_time)) * 24) || ':' || lpad(mod(round((sysdate - to_date(@start_time)) * 24 * 60), 60), 2, '0') total_time,
        '1st break' break_not_taken
   from dual
  where @no_fst_brk_flg = 1
 union all
 select @usr_id usr_id,
        @user_name user_name,
        @query_date query_date,
        to_char(to_date(@start_time), 'hh24:mi') begin_time,
        to_char(sysdate, 'hh24:mi') current_time,
        round((sysdate - to_date(@start_time)) * 24) || ':' || lpad(mod(round((sysdate - to_date(@start_time)) * 24 * 60), 60), 2, '0') total_time,
        'lunch break' break_not_taken
   from dual
  where @no_lch_brk_flg = 1
 union all
 select @usr_id usr_id,
        @user_name user_name,
        @query_date query_date,
        to_char(to_date(@start_time), 'hh24:mi') begin_time,
        to_char(sysdate, 'hh24:mi') current_time,
        round((sysdate - to_date(@start_time)) * 24) || ':' || lpad(mod(round((sysdate - to_date(@start_time)) * 24 * 60), 60), 2, '0') total_time,
        '2nd break' break_not_taken
   from dual
  where @no_snd_brk_flg = 1] catch(-1403);