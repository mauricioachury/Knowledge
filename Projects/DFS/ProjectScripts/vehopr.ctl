[ select count(*) row_count from vehopr where
    vehtyp = '@vehtyp@' and oprcod = '@oprcod@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update vehopr set
          vehtyp = '@vehtyp@'
,          oprcod = '@oprcod@'
,          wh_id = '@wh_id@'
             where  vehtyp = '@vehtyp@' and oprcod = '@oprcod@' and wh_id = '@wh_id@' ] }
             else { [ insert into vehopr
                      (vehtyp, oprcod, wh_id)
                      VALUES
                      ('@vehtyp@', '@oprcod@', '@wh_id@') ] }
