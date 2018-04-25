[ select count(*) row_count from les_lkp where
    lkp_id = '@lkp_id@' and cust_lvl = @cust_lvl@ ] | if (@row_count > 0) {
       [ update les_lkp set
          lkp_id = '@lkp_id@'
,          cust_lvl = @cust_lvl@
,          lkp_cmd = '@lkp_cmd@'
,          static_cmd_flg = @static_cmd_flg@
,          lkp_comp = '@lkp_comp@'
,          ret_fld = '@ret_fld@'
,          grp_nam = '@grp_nam@'
             where  lkp_id = '@lkp_id@' and cust_lvl = @cust_lvl@ ] }
             else { [ insert into les_lkp
                      (lkp_id, cust_lvl, lkp_cmd, static_cmd_flg, lkp_comp, ret_fld, grp_nam)
                      VALUES
                      ('@lkp_id@', @cust_lvl@, '@lkp_cmd@', @static_cmd_flg@, '@lkp_comp@', '@ret_fld@', '@grp_nam@') ] }
