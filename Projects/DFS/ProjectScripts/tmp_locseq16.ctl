[ select count(*) row_count from tmp_locseq16 where
    stoloc = '@stoloc@' and trvseq = '@trvseq@' ] | if (@row_count > 0) {
       [ update tmp_locseq16 set
          stoloc = '@stoloc@'
,          trvseq = '@trvseq@'
             where  stoloc = '@stoloc@' and trvseq = '@trvseq@' ] }
             else { [ insert into tmp_locseq16
                      (stoloc, trvseq)
                      VALUES
                      ('@stoloc@', '@trvseq@') ] }
