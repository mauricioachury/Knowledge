publish data
 where start_dt = '2018-06-07 01:00'
   and end_dt = '2018-06-07 23:00'
   and usr_id_in = "b.usr_id in ('1080','1187','5015','5005','5028','9841','8424','8436','3542','7007','2114','5045','9016','2110','9902','3908','7013','9917','9998','3627','9926','3787','5057','5085','3893','5079','8555','2100','8466','1283','8508','8499','3895','9019','9995','7713','3774','3798','5089','5007','5059','5077','5081','8000','1055','9087','7012','3831','5009','5075','5200','9015','8448','3830','1330','9187','3887','9713','9656','9904','9997','8403','9913','3946','3711','7607','5088','9004','3804','3914','3891','8414','3999','1080','1187','3452','3810','8415','2106','9844','8531','5090','5066','5098','3927','9114','8446','3476','9803','9842','9050','9999','5018','5048','5094','2109','8520','3793','9024','2112','8459','3756','9009','7715','5039','3716','7005','9588','9010','7011','9915','9840','7790','9029','5032','3795','8426','9036','8498','2101','3876','9727','2107','9150','8423','1238','8533','3886','9907')"
|
if (@usr_id_in = '')
{
    [select distinct a.usr_id
       from kvi_adjustments k,
            jobcode j,
            kvi_summary a
      where k.jobcodeintid = j.jobcodeintid
        and k.kvisummaryintid = a.kvisummaryintid
        and j.jobcodeid in ('LUNCH', 'OVRTBREAK', 'BREAK')
        and to_char(k.adj_start_time, 'yyyy-mm-dd hh24:mi') >= @start_dt
        and to_char(k.adj_start_time, 'yyyy-mm-dd hh24:mi') <= @end_dt
        and a.status in ('C', 'A')] >> res
    |
    convert column results to string
     where colnam = 'usr_id'
       and res = @res
       and separator = ','
    |
    convert list to in clause
     where column_name = 'usr_id'
       and separator = ','
       and string = @result_string
    |
    publish data
     where usr_id_in = 'b.' || @in_clause
}
|
[select distinct to_char(t.start_time, 'yyyy-mm-dd') break_date,
        t.usr_id pin_no,
        t.user_name,
        t.jobcodeid break_type,
        last_work_code,
        nvl(b.tostol, b.frstol) last_location_before_break,
        b.trndte last_work_time_before_break,
        floor((t.start_time - b.trndte) * 24 * 60) last_work_to_break_in_minute,
        t.start_time break_time,
        floor((a.trndte - t.start_time) * 24 * 60) break_to_first_work_in_minute,
        a.trndte first_work_time_after_break,
        nvl(a.frstol, b.tostol) first_location_after_break
   from (select distinct a.usr_id,
                uv.last_name || ',' || uv.first_name as user_name,
                j.jobcodeid,
                a.jobcodeid last_work_code,
                k.adj_start_time as start_time
           from kvi_adjustments k,
                jobcode j,
                kvi_summary a,
                users_view uv
          where a.kvisummaryintid = k.kvisummaryintid
            and j.jobcodeintid = k.jobcodeintid
            and a.usr_id = uv.usr_id
            and a.status in ('C', 'A')
            and j.jobcodeid in ('LUNCH', 'OVRTBREAK', 'BREAK')) t,
        dlytrn b,
        dlytrn a
  where b.usr_id = a.usr_id
    and b.usr_id = t.usr_id
    and @usr_id_in:raw
    and b.trndte < t.start_time
    and a.trndte > t.start_time
    and a.dlytrn_id = (select min(t.dlytrn_id)
                         from dlytrn t
                        where t.usr_id = a.usr_id
                          and t.trndte > t.start_time)
    and b.dlytrn_id = (select max(t.dlytrn_id)
                         from dlytrn t
                        where t.usr_id = b.usr_id
                          and t.trndte < t.start_time)
    and t.jobcodeid in ('LUNCH', 'OVRTBREAK', 'BREAK')
    and to_char(t.start_time, 'yyyy-mm-dd hh24:mi') >= @start_dt
    and to_char(t.start_time, 'yyyy-mm-dd hh24:mi') <= @end_dt
  order by pin_no,
        break_time]