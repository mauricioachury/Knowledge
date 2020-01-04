[ select count(*) row_count
    from les_mls_cat
   where mls_id = '@mls_id@'
     and cust_lvl = @cust_lvl@]
     |
     if (@row_count > 0) {
       [ update les_mls_cat set
          mls_id = '@mls_id@'
,          locale_id = '@locale_id@'
,          prod_id = '@prod_id@'
,          appl_id = '@appl_id@'
,          frm_id = '@frm_id@'
,          vartn = '@vartn@'
,          srt_seq = @srt_seq@
,          cust_lvl = @cust_lvl@
,          mls_text = '@mls_text@'
,          grp_nam = '@grp_nam@'
             where  mls_id = '@mls_id@'
               and locale_id = '@locale_id@'
               and prod_id = '@prod_id@'
               and appl_id = '@appl_id@'
               and frm_id = '@frm_id@'
               and vartn = '@vartn@'
               and srt_seq = @srt_seq@
               and cust_lvl = @cust_lvl@]
             }
             else { [ insert into les_mls_cat
                      (mls_id, locale_id, prod_id, appl_id, frm_id, vartn, srt_seq, cust_lvl, mls_text, grp_nam)
                      VALUES
                      ('@mls_id@', '@locale_id@', '@prod_id@', '@appl_id@', '@frm_id@', '@vartn@', @srt_seq@, @cust_lvl@, '@mls_text@', '@grp_nam@') ] }
