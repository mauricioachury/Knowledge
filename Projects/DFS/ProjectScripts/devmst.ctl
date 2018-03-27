[ select count(*) row_count from devmst where
    devcod = '@devcod@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update devmst set
          devcod = '@devcod@'
,          wh_id = '@wh_id@'
,          devcls = '@devcls@'
,          devnam = '@devnam@'
,          prtadr = '@prtadr@'
,          lst_usr_id = '@lst_usr_id@'
,          lbl_prtadr = '@lbl_prtadr@'
,          rfid_prtadr = '@rfid_prtadr@'
,          locale_id = '@locale_id@'
,          wko_prcloc = '@wko_prcloc@'
,          touchscreen_flg = @touchscreen_flg@
,          pko_prcare = '@pko_prcare@'
,          spl_hand_loc = '@spl_hand_loc@'
,          pko_autoctnnum_flg = @pko_autoctnnum_flg@
,          moddte = sysdate
,          mod_usr_id = '@mod_usr_id@'
,          u_version = to_number('@u_version@')
,          scale_ser_dev_id = '@scale_ser_dev_id@'
,          scanner_ser_dev_id = '@scanner_ser_dev_id@'
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  devcod = '@devcod@' and wh_id = '@wh_id@' ] }
             else { [ insert into devmst
                      (devcod, wh_id, devcls, devnam, prtadr, lst_usr_id, lbl_prtadr, rfid_prtadr, locale_id, wko_prcloc, touchscreen_flg, pko_prcare, spl_hand_loc, pko_autoctnnum_flg, moddte, mod_usr_id, u_version, scale_ser_dev_id, scanner_ser_dev_id, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@devcod@', '@wh_id@', '@devcls@', '@devnam@', '@prtadr@', '@lst_usr_id@', '@lbl_prtadr@', '@rfid_prtadr@', '@locale_id@', '@wko_prcloc@', @touchscreen_flg@, '@pko_prcare@', '@spl_hand_loc@', @pko_autoctnnum_flg@, sysdate, '@mod_usr_id@', to_number('@u_version@'), '@scale_ser_dev_id@', '@scanner_ser_dev_id@', sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
