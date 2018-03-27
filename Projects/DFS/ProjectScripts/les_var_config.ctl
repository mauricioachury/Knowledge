[ select count(*) row_count from les_var_config where
    var_nam = '@var_nam@' and appl_id = '@appl_id@' and frm_id = '@frm_id@' and addon_id = '@addon_id@' and cust_lvl = @cust_lvl@ ] | if (@row_count > 0) {
       [ update les_var_config set
          var_nam = '@var_nam@'
,          appl_id = '@appl_id@'
,          frm_id = '@frm_id@'
,          addon_id = '@addon_id@'
,          cust_lvl = @cust_lvl@
,          vis_flg = @vis_flg@
,          ena_flg = @ena_flg@
,          fld_typ = '@fld_typ@'
,          ctrl_typ = '@ctrl_typ@'
,          ctxt_flg = @ctxt_flg@
,          dsp_wid = to_number('@dsp_wid@')
,          dsp_hgt = to_number('@dsp_hgt@')
,          ctrl_prop = '@ctrl_prop@'
,          grp_nam = '@grp_nam@'
             where  var_nam = '@var_nam@' and appl_id = '@appl_id@' and frm_id = '@frm_id@' and addon_id = '@addon_id@' and cust_lvl = @cust_lvl@ ] }
             else { [ insert into les_var_config
                      (var_nam, appl_id, frm_id, addon_id, cust_lvl, vis_flg, ena_flg, fld_typ, ctrl_typ, ctxt_flg, dsp_wid, dsp_hgt, ctrl_prop, grp_nam)
                      VALUES
                      ('@var_nam@', '@appl_id@', '@frm_id@', '@addon_id@', @cust_lvl@, @vis_flg@, @ena_flg@, '@fld_typ@', '@ctrl_typ@', @ctxt_flg@, to_number('@dsp_wid@'), to_number('@dsp_hgt@'), '@ctrl_prop@', '@grp_nam@') ] }
