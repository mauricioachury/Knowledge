[ select count(*) row_count from locmst where
    stoloc = '@stoloc@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update locmst set
          stoloc = '@stoloc@'
,          wh_id = '@wh_id@'
,          arecod = '@arecod@'
,          locsts = '@locsts@'
,          velzon = '@velzon@'
,          wrkzon = '@wrkzon@'
,          aisle_id = '@aisle_id@'
,          trvseq = '@trvseq@'
,          rescod = '@rescod@'
,          lochgt = to_number('@lochgt@')
,          loclen = to_number('@loclen@')
,          locwid = to_number('@locwid@')
,          locvrc = '@locvrc@'
,          maxqvl = @maxqvl@
,          curqvl = @curqvl@
,          pndqvl = @pndqvl@
,          trfpct = to_number('@trfpct@')
,          erfpct = to_number('@erfpct@')
,          useflg = to_number('@useflg@')
,          stoflg = to_number('@stoflg@')
,          pckflg = to_number('@pckflg@')
,          repflg = to_number('@repflg@')
,          asgflg = to_number('@asgflg@')
,          cipflg = to_number('@cipflg@')
,          cntseq = '@cntseq@'
,          numcnt = @numcnt@
,          abccod = '@abccod@'
,          cntdte = null
,          devcod = '@devcod@'
,          lokcod = '@lokcod@'
,          locacc = '@locacc@'
,          voc_chkdgt = '@voc_chkdgt@'
,          lstdte = null
,          lstcod = '@lstcod@'
,          lst_usr_id = '@lst_usr_id@'
,          slotseq = '@slotseq@'
,          perm_asgflg = to_number('@perm_asgflg@')
,          cntzon_id = '@cntzon_id@'
,          section = '@section@'
,          x = '@x@'
,          y = '@y@'
,          z = '@z@'
,          attr1 = '@attr1@'
,          attr2 = '@attr2@'
,          attr3 = '@attr3@'
,          attr4 = '@attr4@'
,          attr5 = '@attr5@'
,          basepoint_id = '@basepoint_id@'
,          top_left_x = to_number('@top_left_x@')
,          top_left_y = to_number('@top_left_y@')
,          top_right_x = to_number('@top_right_x@')
,          top_right_y = to_number('@top_right_y@')
,          bottom_left_x = to_number('@bottom_left_x@')
,          bottom_left_y = to_number('@bottom_left_y@')
,          bottom_right_x = to_number('@bottom_right_x@')
,          bottom_right_y = to_number('@bottom_right_y@')
,          border_pad = to_number('@border_pad@')
,          auto_mov_flg = @auto_mov_flg@
,          slot_id = '@slot_id@'
,          def_maxqvl = @def_maxqvl@
,          ignore_psh_flg = @ignore_psh_flg@
,          u_version = to_number('@u_version@')
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
,          cntbck_ena_flg = to_number('@cntbck_ena_flg@')
,          prdlin = '@prdlin@'
,          stgloc = '@stgloc@'
             where  stoloc = '@stoloc@' and wh_id = '@wh_id@' ] }
             else { [ insert into locmst
                      (stoloc, wh_id, arecod, locsts, velzon, wrkzon, aisle_id, trvseq, rescod, lochgt, loclen, locwid, locvrc, maxqvl, curqvl, pndqvl, trfpct, erfpct, useflg, stoflg, pckflg, repflg, asgflg, cipflg, cntseq, numcnt, abccod, cntdte, devcod, lokcod, locacc, voc_chkdgt, lstdte, lstcod, lst_usr_id, slotseq, perm_asgflg, cntzon_id, section, x, y, z, attr1, attr2, attr3, attr4, attr5, basepoint_id, top_left_x, top_left_y, top_right_x, top_right_y, bottom_left_x, bottom_left_y, bottom_right_x, bottom_right_y, border_pad, auto_mov_flg, slot_id, def_maxqvl, ignore_psh_flg, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id, cntbck_ena_flg, prdlin, stgloc)
                      VALUES
                      ('@stoloc@', '@wh_id@', '@arecod@', '@locsts@', '@velzon@', '@wrkzon@', '@aisle_id@', '@trvseq@', '@rescod@', to_number('@lochgt@'), to_number('@loclen@'), to_number('@locwid@'), '@locvrc@', @maxqvl@, @curqvl@, @pndqvl@, to_number('@trfpct@'), to_number('@erfpct@'), to_number('@useflg@'), to_number('@stoflg@'), to_number('@pckflg@'), to_number('@repflg@'), to_number('@asgflg@'), to_number('@cipflg@'), '@cntseq@', @numcnt@, '@abccod@', null, '@devcod@', '@lokcod@', '@locacc@', '@voc_chkdgt@', null, '@lstcod@', '@lst_usr_id@', '@slotseq@', to_number('@perm_asgflg@'), '@cntzon_id@', '@section@', '@x@', '@y@', '@z@', '@attr1@', '@attr2@', '@attr3@', '@attr4@', '@attr5@', '@basepoint_id@', to_number('@top_left_x@'), to_number('@top_left_y@'), to_number('@top_right_x@'), to_number('@top_right_y@'), to_number('@bottom_left_x@'), to_number('@bottom_left_y@'), to_number('@bottom_right_x@'), to_number('@bottom_right_y@'), to_number('@border_pad@'), @auto_mov_flg@, '@slot_id@', @def_maxqvl@, @ignore_psh_flg@, to_number('@u_version@'), sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@', to_number('@cntbck_ena_flg@'), '@prdlin@', '@stgloc@') ] }
