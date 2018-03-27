/*
 * [select *
 *    from mov_path h,
 *         mov_path_dtl d
 *   where h.srcare = d.srcare
 *     and h.dstare = d.dstare
 *     and h.lodlvl = d.lodlvl
 *     and h.wh_id = d.wh_id
 *     and (h.srcare in (select arecod
 *                         from aremst
 *                        where bldg_id = 'Greenwich') or h.dstare in (select arecod
 *                                                                       from aremst
 *                                                                      where bldg_id = 'Greenwich'))
 *     and h.ins_user_id = 'SAMNI'
 *   order by h.srcare,
 *         h.dstare,
 *         h.lodlvl,
 *         d.hopseq]
 */

[ select count(*) row_count from mov_path where
    srcare = '@srcare@' and dstare = '@dstare@' and wh_id = '@wh_id@' and lodlvl = '@lodlvl@' ] | if (@row_count > 0) {
       [ update mov_path set
          srcare = '@srcare@'
,          dstare = '@dstare@'
,          wh_id = '@wh_id@'
,          lodlvl = '@lodlvl@'
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  srcare = '@srcare@' and dstare = '@dstare@' and wh_id = '@wh_id@' and lodlvl = '@lodlvl@' ] }
             else { [ insert into mov_path
                      (srcare, dstare, wh_id, lodlvl, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@srcare@', '@dstare@', '@wh_id@', '@lodlvl@', sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
