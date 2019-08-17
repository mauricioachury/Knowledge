[select 'x'
   from wh
  where wh_id = '@wh_id_tmpl@'
 union 
 select 'x'
   from dual
  where '@wh_id_tmpl@' = '----'] catch(-1403)
|
if (@? = 0)
{
    [ select count(*) row_count from poldat where
        polcod = '@polcod@' and polvar = '@polvar@' and polval = '@polval@' and wh_id_tmpl = '@wh_id_tmpl@' and srtseq = @srtseq@] | if (@row_count > 0) {
           [ update poldat set
              polcod = '@polcod@'
    ,          polvar = '@polvar@'
    ,          polval = '@polval@'
    ,          wh_id_tmpl = '@wh_id_tmpl@'
    ,          srtseq = @srtseq@
    ,          rtstr1 = '@rtstr1@'
    ,          rtstr2 = '@rtstr2@'
    ,          rtnum1 = to_number('@rtnum1@')
    ,          rtnum2 = to_number('@rtnum2@')
    ,          rtflt1 = to_number('@rtflt1@')
    ,          rtflt2 = to_number('@rtflt2@')
    ,          moddte =  sysdate
    ,          mod_usr_id = nvl('@mod_usr_id@', 'SUPER')
    ,          grp_nam = '@grp_nam@'
                 where  polcod = '@polcod@' and polvar = '@polvar@' and polval = '@polval@' and wh_id_tmpl = '@wh_id_tmpl@' and srtseq = @srtseq@] }
                 else { [ insert into poldat
                          (polcod, polvar, polval, wh_id_tmpl, srtseq, rtstr1, rtstr2, rtnum1, rtnum2, rtflt1, rtflt2, moddte, mod_usr_id, grp_nam)
                          VALUES
                          ('@polcod@', '@polvar@', '@polval@', '@wh_id_tmpl@', @srtseq@, '@rtstr1@', '@rtstr2@', to_number('@rtnum1@'), to_number('@rtnum2@'), to_number('@rtflt1@'), to_number('@rtflt2@'), sysdate, nvl('@mod_usr_id@','SUPER'), '@grp_nam@') ] }
}