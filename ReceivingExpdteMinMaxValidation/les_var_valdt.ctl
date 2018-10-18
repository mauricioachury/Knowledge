[ select count(*) row_count from les_var_valdt where
    var_nam = '@var_nam@' and appl_id = '@appl_id@' and frm_id = '@frm_id@' and addon_id = '@addon_id@' and cust_lvl = @cust_lvl@ and ena_flg = @ena_flg@ and valdt_mod = '@valdt_mod@' and ret_fld_flg = @ret_fld_flg@ and ret_fld = '@ret_fld@' and grp_nam = '@grp_nam@' ] | if (@row_count > 0) {
       [ update les_var_valdt set
          var_nam = '@var_nam@'
,          appl_id = '@appl_id@'
,          frm_id = '@frm_id@'
,          addon_id = '@addon_id@'
,          cust_lvl = @cust_lvl@
,          valdt_cmd = '@valdt_cmd@'
,          ena_flg = @ena_flg@
,          valdt_mod = '@valdt_mod@'
,          ret_fld_flg = @ret_fld_flg@
,          ret_fld = '@ret_fld@'
,          grp_nam = '@grp_nam@'
             where  var_nam = '@var_nam@' and appl_id = '@appl_id@' and frm_id = '@frm_id@' and addon_id = '@addon_id@' and cust_lvl = @cust_lvl@ and ena_flg = @ena_flg@ and valdt_mod = '@valdt_mod@' and ret_fld_flg = @ret_fld_flg@ and ret_fld = '@ret_fld@' and grp_nam = '@grp_nam@' ] }
             else { [ insert into les_var_valdt
                      (var_nam, appl_id, frm_id, addon_id, cust_lvl, valdt_cmd, ena_flg, valdt_mod, ret_fld_flg, ret_fld, grp_nam)
                      VALUES
                      ('@var_nam@', '@appl_id@', '@frm_id@', '@addon_id@', @cust_lvl@, '@valdt_cmd@', @ena_flg@, '@valdt_mod@', @ret_fld_flg@, '@ret_fld@', '@grp_nam@') ] }
