[ select count(*) row_count from dev_wrkare where
    devcod = '@devcod@' and wrkare = '@wrkare@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update dev_wrkare set
          devcod = '@devcod@'
,          wrkare = '@wrkare@'
,          wh_id = '@wh_id@'
,          u_version = to_number('@u_version@')
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  devcod = '@devcod@' and wrkare = '@wrkare@' and wh_id = '@wh_id@' ] }
             else { [ insert into dev_wrkare
                      (devcod, wrkare, wh_id, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@devcod@', '@wrkare@', '@wh_id@', to_number('@u_version@'), sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
