[ select count(*) row_count from wkamst where
    wrkare = '@wrkare@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update wkamst set
          wrkare = '@wrkare@'
,          wh_id = '@wh_id@'
,          prithr = to_number('@prithr@')
,          hmemaxprithr = to_number('@hmemaxprithr@')
,          maxprithr = to_number('@maxprithr@')
,          voc_cod = to_number('@voc_cod@')
,          dist_thresh = to_number('@dist_thresh@')
,          moddte = sysdate
,          mod_usr_id = '@mod_usr_id@'
             where  wrkare = '@wrkare@' and wh_id = '@wh_id@' ] }
             else { [ insert into wkamst
                      (wrkare, wh_id, prithr, hmemaxprithr, maxprithr, voc_cod, dist_thresh, moddte, mod_usr_id)
                      VALUES
                      ('@wrkare@', '@wh_id@', to_number('@prithr@'), to_number('@hmemaxprithr@'), to_number('@maxprithr@'), to_number('@voc_cod@'), to_number('@dist_thresh@'), sysdate, '@mod_usr_id@') ] }
