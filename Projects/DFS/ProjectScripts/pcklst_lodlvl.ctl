[ select count(*) row_count from pcklst_lodlvl where
    wh_id = '@wh_id@' and arecod = '@arecod@' and lodlvl = '@lodlvl@' ] | if (@row_count > 0) {
       [ update pcklst_lodlvl set
          wh_id = '@wh_id@'
,          arecod = '@arecod@'
,          lodlvl = '@lodlvl@'
,          u_version = to_number('@u_version@')
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  wh_id = '@wh_id@' and arecod = '@arecod@' and lodlvl = '@lodlvl@' ] }
             else { [ insert into pcklst_lodlvl
                      (wh_id, arecod, lodlvl, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@wh_id@', '@arecod@', '@lodlvl@', to_number('@u_version@'), sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
