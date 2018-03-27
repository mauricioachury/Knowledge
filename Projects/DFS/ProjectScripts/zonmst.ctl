[ select count(*) row_count from zonmst where
    wrkzon = '@wrkzon@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update zonmst set
          wrkzon = '@wrkzon@'
,          wh_id = '@wh_id@'
,          wrkare = '@wrkare@'
,          maxdev = to_number('@maxdev@')
,          oosflg = to_number('@oosflg@')
,          trvseq = to_number('@trvseq@')
,          prithr = to_number('@prithr@')
,          maxprithr = to_number('@maxprithr@')
,          moddte = sysdate
,          mod_usr_id = '@mod_usr_id@'
,          u_version = to_number('@u_version@')
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  wrkzon = '@wrkzon@' and wh_id = '@wh_id@' ] }
             else { [ insert into zonmst
                      (wrkzon, wh_id, wrkare, maxdev, oosflg, trvseq, prithr, maxprithr, moddte, mod_usr_id, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@wrkzon@', '@wh_id@', '@wrkare@', to_number('@maxdev@'), to_number('@oosflg@'), to_number('@trvseq@'), to_number('@prithr@'), to_number('@maxprithr@'), sysdate, '@mod_usr_id@', to_number('@u_version@'), sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
