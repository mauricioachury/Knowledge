[ select count(*) row_count from les_cust_fld where
    var_nam = '@var_nam@' and frm_id = '@frm_id@' ] | if (@row_count > 0) {
       [ update les_cust_fld set
          var_nam = '@var_nam@'
,          frm_id = '@frm_id@'
,          ena_flg = @ena_flg@
,          ctrl_typ = '@ctrl_typ@'
,          ctrl_tag = '@ctrl_tag@'
,          par_ctrl = '@par_ctrl@'
,          par_ctrl_idx = to_number('@par_ctrl_idx@')
,          tab_idx = to_number('@tab_idx@')
,          ctrl_wid = to_number('@ctrl_wid@')
,          ctrl_hgt = to_number('@ctrl_hgt@')
,          own_table = '@own_table@'
,          grp_nam = '@grp_nam@'
             where  var_nam = '@var_nam@' and frm_id = '@frm_id@' ] }
             else { [ insert into les_cust_fld
                      (var_nam, frm_id, ena_flg, ctrl_typ, ctrl_tag, par_ctrl, par_ctrl_idx, tab_idx, ctrl_wid, ctrl_hgt, own_table, grp_nam)
                      VALUES
                      ('@var_nam@', '@frm_id@', @ena_flg@, '@ctrl_typ@', '@ctrl_tag@', '@par_ctrl@', to_number('@par_ctrl_idx@'), to_number('@tab_idx@'), to_number('@ctrl_wid@'), to_number('@ctrl_hgt@'), '@own_table@', '@grp_nam@') ] }
