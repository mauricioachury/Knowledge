[ select count(*) row_count from les_var_vp where
    var_nam = '@var_nam@' and appl_id = '@appl_id@' and frm_id = '@frm_id@' and addon_id = '@addon_id@' and cust_lvl = @cust_lvl@ ] | if (@row_count > 0) {
       [ update les_var_vp set
          var_nam = '@var_nam@'
,          appl_id = '@appl_id@'
,          frm_id = '@frm_id@'
,          addon_id = '@addon_id@'
,          cust_lvl = @cust_lvl@
,          lkp_id = '@lkp_id@'
,          ena_flg = @ena_flg@
,          cod_col = '@cod_col@'
,          desc_col = '@desc_col@'
,          add_null_flg = to_number('@add_null_flg@')
,          dis_sgl_flg = to_number('@dis_sgl_flg@')
,          edt_flg = to_number('@edt_flg@')
,          srt_col = '@srt_col@'
,          grd_lkp_cols = '@grd_lkp_cols@'
,          grp_nam = '@grp_nam@'
             where  var_nam = '@var_nam@' and appl_id = '@appl_id@' and frm_id = '@frm_id@' and addon_id = '@addon_id@' and cust_lvl = @cust_lvl@ ] }
             else { [ insert into les_var_vp
                      (var_nam, appl_id, frm_id, addon_id, cust_lvl, lkp_id, ena_flg, cod_col, desc_col, add_null_flg, dis_sgl_flg, edt_flg, srt_col, grd_lkp_cols, grp_nam)
                      VALUES
                      ('@var_nam@', '@appl_id@', '@frm_id@', '@addon_id@', @cust_lvl@, '@lkp_id@', @ena_flg@, '@cod_col@', '@desc_col@', to_number('@add_null_flg@'), to_number('@dis_sgl_flg@'), to_number('@edt_flg@'), '@srt_col@', '@grd_lkp_cols@', '@grp_nam@') ] }
