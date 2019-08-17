[select distinct trlr.*,
        locmst.locsts,
        loc_typ.loc_typ,
        mov_zone.mov_zone_cod,
        locmst.arecod,
        asset.asset_num,
        asset.asset_id,
        asset.asset_tag,
        asset.asset_typ,
        asset.roll_call_flg,
        asset.temp_flg,
        rcvinv_stat.lm_goal_seconds,
        appt.start_dte appt_start_dte,
        appt.end_dte appt_end_dte,
        rcvinv_stat.trknum,
        rcvinv_stat.rcvtrk_stat,
        rcvinv_stat.rec_loc,
        rcvinv_stat.supnum,
        rcvinv_stat.sup_count,
        car_move.car_move_id,
        (case when trlr.safe_sts in ('F', 'R') then 1
              else 0
         end) safety,
        (case when trlr.safe_sts = 'W' then 1
              else 0
         end) need_safety,
        decode(loc_typ.loc_typ_cat, 'YARD', 1, 0) yard_flg,
        decode(trailer_work_view.srcloc, null, 0, 1) pendingMove,
        (case when trlr.trlr_stat = 'SUSP' then 1
              else 0
         end) suspended_flg,
        nvl(pend_aud_wrkque.penaudflg, 0) pending_audit_flg,
        powerunit.carcod powerunit_carrier,
        powerunit.powerunit_num,
        powerunit.powerunit_type
   from trlr
   left outer
   join (select asset_link.asset_num,
                asset_link.asset_id,
                ser_asset.asset_tag,
                ser_asset.asset_typ,
                ser_asset.roll_call_flg,
                asset_typ.temp_flg
           from asset_link,
                ser_asset,
                asset_typ
          where ser_asset.asset_id = asset_link.asset_id
            and asset_typ.asset_typ = ser_asset.asset_typ
            and asset_typ.asset_cat = 'TRL'
            and asset_typ.ser_flg = 1) asset
     on asset.asset_num = trlr.carcod || '|' || trlr.trlr_num
   left outer
   join (select rcvtrk.trlr_id,
                count(distinct rcvinv.supnum) sup_count,
                decode(count(distinct rcvinv.supnum), 1, min(rcvinv.supnum), 0, NULL, '*MANY*') supnum,
                sum(nvl(rcvtrk.lm_goal_seconds, 0)) lm_goal_seconds,
                decode(count(distinct rcvtrk.trknum), 1, min(rcvtrk.trknum), 0, NULL, '*MANY*') trknum,
                decode(count(distinct rcvtrk.rcvtrk_stat), 1, min(rcvtrk.rcvtrk_stat), 0, NULL, '*MANY*') rcvtrk_stat,
                decode(count(distinct rcvtrk.rec_loc), 1, min(rcvtrk.rec_loc), 0, NULL, '*MANY*') rec_loc
           from rcvtrk
           left
           join rcvinv
             on rcvtrk.trknum = rcvinv.trknum
            and rcvtrk.wh_id = rcvinv.wh_id
          group by rcvtrk.trlr_id) rcvinv_stat
     on trlr.trlr_id = rcvinv_stat.trlr_id
   left outer
   join appt
     on trlr.appt_id = appt.appt_id
    and trlr.stoloc_wh_id = appt.wh_id
   left
   join wrkque trailer_work_view
     on trailer_work_view.srcloc = trlr.yard_loc
    and trailer_work_view.oprcod = 'TRL'
    and trailer_work_view.wh_id = 'HIRV'
    and trailer_work_view.refloc = trlr.trlr_num
   left outer
   join car_move
     on car_move.trlr_id = trlr.trlr_id
        /*
         * Pending trailer audit in the workqueue is TAUD and PEND
         */
   left outer
   join (select count(*) penaudflg,
                srcloc,
                wh_id
           from wrkque
          where oprcod = 'TAUD'
            and wrksts = 'PEND'
          group by wh_id,
                srcloc,
                wrksts) pend_aud_wrkque
     on (trlr.yard_loc = pend_aud_wrkque.srcloc and trlr.yard_loc_wh_id = pend_aud_wrkque.wh_id)
   left
   join locmst
     on locmst.stoloc = trlr.yard_loc
    and locmst.wh_Id = trlr.yard_loc_wh_Id
   left
   join loc_typ
     on loc_typ.loc_typ_id = locmst.loc_typ_id
   left
   join mov_zone
     on mov_zone.mov_zone_id = locmst.mov_zone_id
   left
   join powerunit
     on powerunit.powerunit_id = trlr.powerunit_id
  where 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and trlr.stoloc_wh_id = 'HIRV'
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
 --and trlr.trlr_stat = 'EX'

    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and 1 = 1
    and (trlr.trlr_num like '%TRL0410723%')
  order by trlr.trlr_num];

/* Original value is 'LDG' */
[select car_move_id,
        wh_id,
        stop_id
   from ship_struct_view
  where trlr_id = 'TRL0410723'];
[update trlr
    set trlr_stat = 'L'
  where trlr_id = 'TRL0410723'];
[select *
   from trlr
  where trlr_id = 'TRL0410723'];
[select distinct trlr_stat
   from trlr]
[select *
   from stop
  where stop_id = 'STP0405497']
[select *
   from dlytrn
  where to_lodnum = 'L00010943MTY'];
[select stoloc
   from inventory_view
  where lodnum = 'L00010943EG8'];
load trailer
 where actcod = 'TRLR_LOAD'
   and lodnum = 'L00010943EG8'
   and car_move_id = 'LD00405320'
   and wh_id = 'HIRV'
   and dstloc = 'TRL0410723'
   and srcloc = 'SP-STG-W-01';
[select lodnum,
        stoloc
   from inventory_view iv
  where iv.stoloc in ('TRL0410723', 'DOOR-SHP-E-05')];
[update stop
    set stop_cmpl_flg = 1
  where stop_id = 'STP0405497'];
[select *
   from codmst
  where  colnam = 'trlr_stat']