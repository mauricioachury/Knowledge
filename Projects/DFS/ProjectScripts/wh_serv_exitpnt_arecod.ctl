[ select count(*) row_count from wh_serv_exitpnt_arecod where
    serv_id = '@serv_id@' and wh_id = '@wh_id@' and exitpnt_typ = '@exitpnt_typ@' and exitpnt = '@exitpnt@' and srcare = '@srcare@' and dstare = '@dstare@' ] | if (@row_count > 0) {
       [ update wh_serv_exitpnt_arecod set
          serv_id = '@serv_id@'
,          wh_id = '@wh_id@'
,          exitpnt_typ = '@exitpnt_typ@'
,          exitpnt = '@exitpnt@'
,          srcare = '@srcare@'
,          dstare = '@dstare@'
,          moddte = sysdate
,          mod_usr_id = '@mod_usr_id@'
             where  serv_id = '@serv_id@' and wh_id = '@wh_id@' and exitpnt_typ = '@exitpnt_typ@' and exitpnt = '@exitpnt@' and srcare = '@srcare@' and dstare = '@dstare@' ] }
             else { [ insert into wh_serv_exitpnt_arecod
                      (serv_id, wh_id, exitpnt_typ, exitpnt, srcare, dstare, moddte, mod_usr_id)
                      VALUES
                      ('@serv_id@', '@wh_id@', '@exitpnt_typ@', '@exitpnt@', '@srcare@', '@dstare@', sysdate, '@mod_usr_id@') ] }
