[ select count(*) row_count from reltyp_cmd where
    wh_id = '@wh_id@' and reltyp_id = '@reltyp_id@' and srcare = '@srcare@' ] | if (@row_count > 0) {
       [ update reltyp_cmd set
          wh_id = '@wh_id@'
,          reltyp_id = '@reltyp_id@'
,          srcare = '@srcare@'
,          rel_cmd = '@rel_cmd@'
,          extra_args = '@extra_args@'
,          pricod = to_number('@pricod@')
,          grp_cols = '@grp_cols@'
,          ins_dt = sysdate 
,          last_upd_dt = sysdate 
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  wh_id = '@wh_id@' and reltyp_id = '@reltyp_id@' and srcare = '@srcare@' ] }
             else { [ insert into reltyp_cmd
                      (wh_id, reltyp_id, srcare, rel_cmd, extra_args, pricod, grp_cols, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@wh_id@', '@reltyp_id@', '@srcare@', '@rel_cmd@', '@extra_args@', to_number('@pricod@'), '@grp_cols@', sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
