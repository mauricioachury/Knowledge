[ select count(*) row_count from rf_frm_mst where
    rf_frm = '@rf_frm@' and cust_lvl = @cust_lvl@ ] | if (@row_count > 0) {
       [ update rf_frm_mst set
          rf_frm = '@rf_frm@'
,          cust_lvl = @cust_lvl@
,          frm_cls = '@frm_cls@'
,          grp_nam = '@grp_nam@'
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  rf_frm = '@rf_frm@' and cust_lvl = @cust_lvl@ ] }
             else { [ insert into rf_frm_mst
                      (rf_frm, cust_lvl, frm_cls, grp_nam, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@rf_frm@', @cust_lvl@, '@frm_cls@', '@grp_nam@', sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
