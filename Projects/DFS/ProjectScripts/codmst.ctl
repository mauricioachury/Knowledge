[ select count(*) row_count from codmst where
    colnam = '@colnam@' and codval = '@codval@' ] | if (@row_count > 0) {
       [ update codmst set
          colnam = '@colnam@'
,          codval = '@codval@'
,          srtseq = @srtseq@
,          rqdflg = to_number('@rqdflg@')
,          img_id = '@img_id@'
,          grp_nam = '@grp_nam@'
             where  colnam = '@colnam@' and codval = '@codval@' ] }
             else { [ insert into codmst
                      (colnam, codval, srtseq, rqdflg, img_id, grp_nam)
                      VALUES
                      ('@colnam@', '@codval@', @srtseq@, to_number('@rqdflg@'), '@img_id@', '@grp_nam@') ] }
