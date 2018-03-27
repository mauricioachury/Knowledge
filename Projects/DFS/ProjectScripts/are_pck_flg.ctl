[ select count(*) row_count from are_pck_flg where
    srcare = '@srcare@' and lodlvl = '@lodlvl@' and wrktyp = '@wrktyp@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update are_pck_flg set
          srcare = '@srcare@'
,          lodlvl = '@lodlvl@'
,          wrktyp = '@wrktyp@'
,          wh_id = '@wh_id@'
,          lotflg = to_number('@lotflg@')
,          sup_lot_flg = to_number('@sup_lot_flg@')
,          revflg = to_number('@revflg@')
,          orgflg = to_number('@orgflg@')
,          supflg = to_number('@supflg@')
,          dtlflg = to_number('@dtlflg@')
,          subflg = to_number('@subflg@')
,          lodflg = to_number('@lodflg@')
,          prtflg = to_number('@prtflg@')
,          locflg = to_number('@locflg@')
,          qtyflg = to_number('@qtyflg@')
,          catch_qty_flg = to_number('@catch_qty_flg@')
,          mandte_flg = to_number('@mandte_flg@')
,          expdte_flg = to_number('@expdte_flg@')
,          attr_str1_flg = to_number('@attr_str1_flg@')
,          attr_str2_flg = to_number('@attr_str2_flg@')
,          attr_str3_flg = to_number('@attr_str3_flg@')
,          attr_str4_flg = to_number('@attr_str4_flg@')
,          attr_str5_flg = to_number('@attr_str5_flg@')
,          attr_str6_flg = to_number('@attr_str6_flg@')
,          attr_str7_flg = to_number('@attr_str7_flg@')
,          attr_str8_flg = to_number('@attr_str8_flg@')
,          attr_str9_flg = to_number('@attr_str9_flg@')
,          attr_str10_flg = to_number('@attr_str10_flg@')
,          attr_int1_flg = to_number('@attr_int1_flg@')
,          attr_int2_flg = to_number('@attr_int2_flg@')
,          attr_int3_flg = to_number('@attr_int3_flg@')
,          attr_int4_flg = to_number('@attr_int4_flg@')
,          attr_int5_flg = to_number('@attr_int5_flg@')
,          attr_flt1_flg = to_number('@attr_flt1_flg@')
,          attr_flt2_flg = to_number('@attr_flt2_flg@')
,          attr_flt3_flg = to_number('@attr_flt3_flg@')
,          attr_dte1_flg = to_number('@attr_dte1_flg@')
,          attr_dte2_flg = to_number('@attr_dte2_flg@')
,          rttn_id_flg = to_number('@rttn_id_flg@')
,          moddte = sysdate
,          mod_usr_id = '@mod_usr_id@'
,          u_version = to_number('@u_version@')
,          ins_dt = sysdate
,          last_upd_dt = sysdate 
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  srcare = '@srcare@' and lodlvl = '@lodlvl@' and wrktyp = '@wrktyp@' and wh_id = '@wh_id@' ] }
             else { [ insert into are_pck_flg
                      (srcare, lodlvl, wrktyp, wh_id, lotflg, sup_lot_flg, revflg, orgflg, supflg, dtlflg, subflg, lodflg, prtflg, locflg, qtyflg, catch_qty_flg, mandte_flg, expdte_flg, attr_str1_flg, attr_str2_flg, attr_str3_flg, attr_str4_flg, attr_str5_flg, attr_str6_flg, attr_str7_flg, attr_str8_flg, attr_str9_flg, attr_str10_flg, attr_int1_flg, attr_int2_flg, attr_int3_flg, attr_int4_flg, attr_int5_flg, attr_flt1_flg, attr_flt2_flg, attr_flt3_flg, attr_dte1_flg, attr_dte2_flg, rttn_id_flg, moddte, mod_usr_id, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@srcare@', '@lodlvl@', '@wrktyp@', '@wh_id@', to_number('@lotflg@'), to_number('@sup_lot_flg@'), to_number('@revflg@'), to_number('@orgflg@'), to_number('@supflg@'), to_number('@dtlflg@'), to_number('@subflg@'), to_number('@lodflg@'), to_number('@prtflg@'), to_number('@locflg@'), to_number('@qtyflg@'), to_number('@catch_qty_flg@'), to_number('@mandte_flg@'), to_number('@expdte_flg@'), to_number('@attr_str1_flg@'), to_number('@attr_str2_flg@'), to_number('@attr_str3_flg@'), to_number('@attr_str4_flg@'), to_number('@attr_str5_flg@'), to_number('@attr_str6_flg@'), to_number('@attr_str7_flg@'), to_number('@attr_str8_flg@'), to_number('@attr_str9_flg@'), to_number('@attr_str10_flg@'), to_number('@attr_int1_flg@'), to_number('@attr_int2_flg@'), to_number('@attr_int3_flg@'), to_number('@attr_int4_flg@'), to_number('@attr_int5_flg@'), to_number('@attr_flt1_flg@'), to_number('@attr_flt2_flg@'), to_number('@attr_flt3_flg@'), to_number('@attr_dte1_flg@'), to_number('@attr_dte2_flg@'), to_number('@rttn_id_flg@'), sysdate, '@mod_usr_id@', to_number('@u_version@'), sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
