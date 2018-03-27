[ select count(*) row_count from mov_path_dtl where
    srcare = '@srcare@' and dstare = '@dstare@' and wh_id = '@wh_id@' and lodlvl = '@lodlvl@' and hopare = '@hopare@' ] | if (@row_count > 0) {
       [select 'head_should_exists'
          from mov_path
         where srcare = '@srcare@'
           and dstare = '@dstare@'
           and lodlvl = '@lodlvl@'
           and wh_id = '@wh_id@']
       |
       [ update mov_path_dtl set
          srcare = '@srcare@'
,          dstare = '@dstare@'
,          wh_id = '@wh_id@'
,          lodlvl = '@lodlvl@'
,          hopseq = @hopseq@
,          hopare = '@hopare@'
,          move_method = '@move_method@'
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  srcare = '@srcare@' and dstare = '@dstare@' and wh_id = '@wh_id@' and lodlvl = '@lodlvl@' and hopare = '@hopare@' ] }
             else {
 [select 'head_should_exists'
    from mov_path
   where srcare = '@srcare@'
     and dstare = '@dstare@'
     and lodlvl = '@lodlvl@'
     and wh_id = '@wh_id@']
 |
 [ insert into mov_path_dtl
                      (srcare, dstare, wh_id, lodlvl, hopseq, hopare, move_method, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@srcare@', '@dstare@', '@wh_id@', '@lodlvl@', @hopseq@, '@hopare@', '@move_method@', sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
