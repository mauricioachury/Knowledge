[ select count(*) row_count from rpl_path_cfg where
    rpl_path_typ = '@rpl_path_typ@' and wh_id = '@wh_id@' and dstare = '@dstare@' and cfgtyp = '@cfgtyp@' and cfgval = '@cfgval@' and rplare = '@rplare@' ] | if (@row_count > 0) {
       [ update rpl_path_cfg set
          rpl_path_typ = '@rpl_path_typ@'
,          wh_id = '@wh_id@'
,          dstare = '@dstare@'
,          cfgtyp = '@cfgtyp@'
,          cfgval = '@cfgval@'
,          rplare = '@rplare@'
,          rpl_lodlvl = '@rpl_lodlvl@'
,          srtseq = @srtseq@
,          hopare = '@hopare@'
,          hop_lodlvl = '@hop_lodlvl@'
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  rpl_path_typ = '@rpl_path_typ@' and wh_id = '@wh_id@' and dstare = '@dstare@' and cfgtyp = '@cfgtyp@' and cfgval = '@cfgval@' and rplare = '@rplare@' ] }
             else { [ insert into rpl_path_cfg
                      (rpl_path_typ, wh_id, dstare, cfgtyp, cfgval, rplare, rpl_lodlvl, srtseq, hopare, hop_lodlvl, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@rpl_path_typ@', '@wh_id@', '@dstare@', '@cfgtyp@', '@cfgval@', '@rplare@', '@rpl_lodlvl@', @srtseq@, '@hopare@', '@hop_lodlvl@', sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
