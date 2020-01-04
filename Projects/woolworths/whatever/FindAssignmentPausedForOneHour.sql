publish data
 where minutes_to_check = 60
|
[select nvl(q.ack_usr_id, lstpk.last_pck_usr_id) usr_id,
        uv.first_name || ', ' || uv.last_name usrnam,
        dm.lngdsc oprcod,
        decode(substr(lstpk.srcare, 1, 1), 'P', 'PRODUCE', 'C', 'CHILLR', 'A', 'AMBIENT') building,
        lstpk.list_id,
        zm.wrkzon,
        nvl(q.ackdevcod, lstpk.ackdevcod) devcod,
        cm.car_move_id,
        to_char(s.early_shpdte, 'hh24:mi:ss') seal_time,
        lstpk.srcloc lst_pck_loc,
        to_char(lstpk.pckdte, 'hh24:mi:ss') lst_pck_time,
        lstpk.list_seqnum
   from wrkque q
   join dscmst dm
     on dm.colnam = 'oprcod|wh_id_tmpl'
    and dm.colval = q.oprcod || '|' || q.wh_id
   join pckwrk_view lstpk
     on lstpk.list_id = q.list_id
    and lstpk.appqty > 0
   join zonmst zm
     on lstpk.src_wrk_zone_id = zm.wrk_zone_id
    and lstpk.wh_id = zm.wh_id
   join shipment s
     on lstpk.ship_id = s.ship_id
    and lstpk.wh_id = s.wh_id
   join stop t
     on s.stop_id = t.stop_id
   join car_move cm
     on t.car_move_id = cm.car_move_id
   join users_view uv
     on nvl(q.ack_usr_id, lstpk.last_pck_usr_id) = uv.usr_id
  where lstpk.pckdte = (select max(ph.pckdte)
                          from pckwrk_hdr ph
                         where ph.appqty > 0
                           and ph.list_id = lstpk.list_id)
    and exists(select 'x'
                 from pckwrk_hdr ph
                where ph.appqty = 0
                  and ph.list_id = lstpk.list_id)
    and lstpk.pckdte < sysdate - @minutes_to_check / 60 / 24]
|
[select distinct pm.stoloc
   from pckwrk_view ph
   join pckmov pm
     on ph.cmbcod = pm.cmbcod
    and ph.wh_id = pm.wh_id
  where ph.list_id = @list_id] >> res
|
convert column results to string
 where resultset = @res
   and colnam = 'stoloc'
   and separator = ','
|
publish data
 where stage_lane = @result_string
|
[select round(sum(pv.appqty) / sum(pv.pckqty), 2) *100 || '%' complete_pct
   from pckwrk_view pv
  where pv.list_id = @list_id]
|
[select distinct iv.lodnum,
        iv.stoloc
   from inventory_view iv
   join pckwrk_view pv
     on iv.ship_line_id = pv.ship_line_id
    and iv.wh_id = pv.wh_id
  where pv.list_id = @list_id] >> res
|
convert column results to string
 where resultset = @res
   and colnam = 'stoloc'
   and separator = ','
|
publish data
 where lpn_loc = @result_string
|
convert column results to string
 where resultset = @res
   and colnam = 'lodnum'
   and separator = ','
|
publish data
 where lpn = @result_string
|
publish data
 where usr_id = @usr_id
   and usrnam = @usrnam
   and oprcod = @oprcod
   and building = @building
   and list_id = @list_id
   and wrkzon = @wrkzon
   and devcod = @devcod
   and stglne = @stage_lane
   and load = @car_move_id
   and seal_time = @seal_time
   and lst_pck_loc = @lst_pck_loc
   and lst_pck_time = @lst_pck_time
   and complete_pct = @complete_pct
   and lpn = @lpn
   and lpn_loc = @lpn_loc