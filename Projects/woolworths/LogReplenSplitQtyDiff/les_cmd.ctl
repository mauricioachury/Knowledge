[ select count(*) row_count from les_cmd where
    les_cmd_id = '@les_cmd_id@' and cust_lvl = @cust_lvl@ ] | if (@row_count > 0) {
       [ update les_cmd set
          les_cmd_id = '@les_cmd_id@'
,          cust_lvl = @cust_lvl@
,          syntax = '@syntax@'
,          moddte = sysdate
,          mod_usr_id = '@mod_usr_id@'
,          grp_nam = '@grp_nam@'
             where  les_cmd_id = '@les_cmd_id@' and cust_lvl = @cust_lvl@ ] }
             else { [ insert into les_cmd
                      (les_cmd_id, cust_lvl, syntax, moddte, mod_usr_id, grp_nam)
                      VALUES
                      ('@les_cmd_id@', @cust_lvl@, '@syntax@', sysdate, '@mod_usr_id@', '@grp_nam@') ] }
