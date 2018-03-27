[ select count(*) row_count from pck_bldg_seq where
    wh_id = '@wh_id@' and dst_bldg_id = '@dst_bldg_id@' and src_bldg_id = '@src_bldg_id@' ] | if (@row_count > 0) {
       [ update pck_bldg_seq set
          wh_id = '@wh_id@'
,          dst_bldg_id = '@dst_bldg_id@'
,          src_bldg_id = '@src_bldg_id@'
,          srtseq = @srtseq@
             where  wh_id = '@wh_id@' and dst_bldg_id = '@dst_bldg_id@' and src_bldg_id = '@src_bldg_id@' ] }
             else { [ insert into pck_bldg_seq
                      (wh_id, dst_bldg_id, src_bldg_id, srtseq)
                      VALUES
                      ('@wh_id@', '@dst_bldg_id@', '@src_bldg_id@', @srtseq@) ] }
