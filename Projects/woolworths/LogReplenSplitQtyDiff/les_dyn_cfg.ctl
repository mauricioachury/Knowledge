[ select count(*) row_count from les_dyn_cfg where
    dyn_cfg_id = '@dyn_cfg_id@' and frm_id = '@frm_id@' and cust_lvl = @cust_lvl@ ] | if (@row_count > 0) {
       [ update les_dyn_cfg set
          dyn_cfg_id = '@dyn_cfg_id@'
,          appl_id = '@appl_id@'
,          frm_id = '@frm_id@'
,          addon_id = '@addon_id@'
,          cust_lvl = @cust_lvl@
,          inp_mod = '@inp_mod@'
,          var_nam_lst = '@var_nam_lst@'
,          les_cmd_id = '@les_cmd_id@'
,          moddte = sysdate
,          mod_usr_id = '@mod_usr_id@'
,          grp_nam = '@grp_nam@'
             where  dyn_cfg_id = '@dyn_cfg_id@' and frm_id = '@frm_id@' and cust_lvl = @cust_lvl@ ] }
             else { [ insert into les_dyn_cfg
                      (dyn_cfg_id, appl_id, frm_id, addon_id, cust_lvl, inp_mod, var_nam_lst, les_cmd_id, moddte, mod_usr_id, grp_nam)
                      VALUES
                      ('@dyn_cfg_id@', '@appl_id@', '@frm_id@', '@addon_id@', @cust_lvl@, '@inp_mod@', '@var_nam_lst@', '@les_cmd_id@', sysdate, '@mod_usr_id@', '@grp_nam@') ] }
