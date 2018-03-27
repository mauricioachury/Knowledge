[ select count(*) row_count from are_invmix_rule where
    arecod = '@arecod@' and wh_id = '@wh_id@' and tblnme = '@tblnme@' and column_name = '@column_name@' ] | if (@row_count > 0) {
       [ update are_invmix_rule set
          arecod = '@arecod@'
,          wh_id = '@wh_id@'
,          tblnme = '@tblnme@'
,          column_name = '@column_name@'
,          srtseq = to_number('@srtseq@')
,          mod_usr_id = '@mod_usr_id@'
,          moddte = sysdate
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  arecod = '@arecod@' and wh_id = '@wh_id@' and tblnme = '@tblnme@' and column_name = '@column_name@' ] }
             else { [ insert into are_invmix_rule
                      (arecod, wh_id, tblnme, column_name, srtseq, mod_usr_id, moddte, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@arecod@', '@wh_id@', '@tblnme@', '@column_name@', to_number('@srtseq@'), '@mod_usr_id@', sysdate, sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
