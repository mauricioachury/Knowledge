publish data where user_id = '8549'
and frm_dt = '2018-06-13 00:00:00'
and to_dt = '2018-06-13 24:00:00'
|
remote('http://ncdwwmsasp0004:49000/service')
{
[select count(distinct lodnum) palcnt
   from dlytrn d 
 where usr_id = @user_id 
     and actcod = 'TRLR_LOAD'
     and to_char(trndte, 'yyyy-mm-dd hh24:mi:ss') >= @frm_dt
     and to_char(trndte, 'yyyy-mm-dd hh24:mi:ss') <= @to_dt
    and  to_arecod = 'SHIP']
}
|
[select nvl(@palcnt, 0) + nvl(count(distinct lodnum), 0) totalPalletLoaded
   from dlytrn d 
  where usr_id = @user_id 
    and actcod = 'TRLR_LOAD'
    and to_char(trndte, 'yyyy-mm-dd hh24:mi:ss') >= @frm_dt
    and to_char(trndte, 'yyyy-mm-dd hh24:mi:ss') <= @to_dt
    and  to_arecod = 'SHIP']