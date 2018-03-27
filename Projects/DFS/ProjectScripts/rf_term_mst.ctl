[ select count(*) row_count from rf_term_mst where
    rf_ven_nam = '@rf_ven_nam@' and wh_id = '@wh_id@' and term_id = '@term_id@' ] | if (@row_count > 0) {
       [ update rf_term_mst set
          rf_ven_nam = '@rf_ven_nam@'
,          wh_id = '@wh_id@'
,          term_id = '@term_id@'
,          dsply_wid = @dsply_wid@
,          dsply_hgt = @dsply_hgt@
,          term_typ = '@term_typ@'
,          devcod = '@devcod@'
,          locale_id = '@locale_id@'
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
,          recplycod = '@recplycod@'
,          recplyfil = '@recplyfil@'
             where  rf_ven_nam = '@rf_ven_nam@' and wh_id = '@wh_id@' and term_id = '@term_id@' ] }
             else { [ insert into rf_term_mst
                      (rf_ven_nam, wh_id, term_id, dsply_wid, dsply_hgt, term_typ, devcod, locale_id, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id, recplycod, recplyfil)
                      VALUES
                      ('@rf_ven_nam@', '@wh_id@', '@term_id@', @dsply_wid@, @dsply_hgt@, '@term_typ@', '@devcod@', '@locale_id@', sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@', '@recplycod@', '@recplyfil@') ] }
