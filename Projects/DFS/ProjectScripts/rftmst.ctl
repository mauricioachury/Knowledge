[ select count(*) row_count from rftmst where
    devcod = '@devcod@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update rftmst set
          devcod = '@devcod@'
,          wh_id = '@wh_id@'
,          curwrkare = '@curwrkare@'
,          curwrkzon = '@curwrkzon@'
,          curstoloc = '@curstoloc@'
,          hmewrkare = '@hmewrkare@'
,          vehtyp = '@vehtyp@'
,          rftmod = '@rftmod@'
,          actdte = sysdate
,          moddte = sysdate
,          mod_usr_id = '@mod_usr_id@'
             where  devcod = '@devcod@' and wh_id = '@wh_id@' ] }
             else { [ insert into rftmst
                      (devcod, wh_id, curwrkare, curwrkzon, curstoloc, hmewrkare, vehtyp, rftmod, actdte, moddte, mod_usr_id)
                      VALUES
                      ('@devcod@', '@wh_id@', '@curwrkare@', '@curwrkzon@', '@curstoloc@', '@hmewrkare@', '@vehtyp@', '@rftmod@', sysdate, sysdate, '@mod_usr_id@') ] }
