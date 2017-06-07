[ select count(*) row_count from locmst where
    stoloc = '@stoloc@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update locmst set
          stoloc = '@stoloc@'
,          wh_id = '@wh_id@'
,          arecod = '@arecod@'
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
,          trfpct = decode('@trfpct@', '','', to_number('@trfpct@'))
,          erfpct = decode('@erfpct@', '','', to_number('@erfpct@'))
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
,          lstdte = sysdate
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
,          vc_wgtlmt = to_number('@vc_wgtlmt@')
,          vc_stggrp_id = '@vc_stggrp_id@'
,          vc_instg_id = '@vc_instg_id@'
,          vc_outstg_id = '@vc_outstg_id@'
,          vc_stoseq = to_number('@vc_stoseq@')
,          vc_beam_id = '@vc_beam_id@'
,          vc_beam_pos = to_number('@vc_beam_pos@')
,          vc_curwgt = to_number('@vc_curwgt@')
             where  stoloc = '@stoloc@' and wh_id = '@wh_id@' ] }
 else { 
             	[ insert into locmst
                      (stoloc, wh_id, arecod, locsts, velzon, wrkzon, aisle_id, trvseq, rescod, lochgt, loclen, locwid, locvrc, maxqvl, curqvl, pndqvl, trfpct, erfpct, useflg, stoflg, pckflg, repflg, asgflg, cipflg, cntseq, numcnt, abccod, cntdte, devcod, lokcod, locacc, voc_chkdgt, lstdte, lstcod, lst_usr_id, slotseq, perm_asgflg, cntzon_id, section, x, y, z, attr1, attr2, attr3, attr4, attr5, basepoint_id, top_left_x, top_left_y, top_right_x, top_right_y, bottom_left_x, bottom_left_y, bottom_right_x, bottom_right_y, border_pad, auto_mov_flg, slot_id, def_maxqvl, ignore_psh_flg, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id, cntbck_ena_flg, prdlin, stgloc, vc_wgtlmt, vc_stggrp_id, vc_instg_id, vc_outstg_id, vc_stoseq, vc_beam_id, vc_beam_pos, vc_curwgt)
                      VALUES
                      ('@stoloc@', '@wh_id@', '@arecod@', '@locsts@', '@velzon@', '@wrkzon@', '@aisle_id@', '@trvseq@', '@rescod@', to_number('@lochgt@'), to_number('@loclen@'), to_number('@locwid@'), '@locvrc@', @maxqvl@, @curqvl@, @pndqvl@, decode('@trfpct@','','', to_number('@trfpct@')), decode('@erfpct@','','', to_number('@erfpct@')), to_number('@useflg@'), to_number('@stoflg@'), to_number('@pckflg@'), to_number('@repflg@'), to_number('@asgflg@'), to_number('@cipflg@'), '@cntseq@', @numcnt@, '@abccod@', null, '@devcod@', '@lokcod@', '@locacc@', '@voc_chkdgt@', sysdate, '@lstcod@', '@lst_usr_id@', '@slotseq@', to_number('@perm_asgflg@'), '@cntzon_id@', '@section@', '@x@', '@y@', '@z@', '@attr1@', '@attr2@', '@attr3@', '@attr4@', '@attr5@', '@basepoint_id@', to_number('@top_left_x@'), to_number('@top_left_y@'), to_number('@top_right_x@'), to_number('@top_right_y@'), to_number('@bottom_left_x@'), to_number('@bottom_left_y@'), to_number('@bottom_right_x@'), to_number('@bottom_right_y@'), to_number('@border_pad@'), @auto_mov_flg@, '@slot_id@', @def_maxqvl@, @ignore_psh_flg@, to_number('@u_version@'), sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@', decode('@cntbck_ena_flg@','','', to_number('@cntbck_ena_flg@')), '@prdlin@', '@stgloc@', decode('@vc_wgtlmt@','','', to_number('@vc_wgtlmt@')), '@vc_stggrp_id@', '@vc_instg_id@', '@vc_outstg_id@', decode('@vc_stoseq@','','', to_number('@vc_stoseq@')), '@vc_beam_id@', decode('@vc_beam_pos@','','', to_number('@vc_beam_pos@')), to_number('@vc_curwgt@')) ] 
}
;

/* Create work zone if it is not created yet */
if ('@wrkzon@' <> '')
{
    [select 'x' from zonmst where wrkzon = '@wrkzon@' and wh_id = '@wh_id@'] catch(-1403)
    |
    if (@? = -1403)
    {
        if ('@arecod@' = '4MEZSTR1')
        {
            publish data
              where wrkare = 'MEZWARE'
        }
        else if ('@arecod@' = '4LGMSTR1')
        {
            publish data
              where wrkare = 'LGMWARE'
        }
        else if ('@arecod@' = '2WCSSTR1')
        {
            publish data
              where wrkare = 'WCS'
        }
        else if ('@arecod@' = '4BLKSTR1')
        {
            publish data
              where wrkare = 'BLKARE'
        }
        else if ('@arecod@' = '4TMPSTR1')
        {
            publish data
              where wrkare = 'TMPWARE'
        }
        else
        {
            publish data
              where wrkare = 'STD'
        }
        |
        create work zone
            where wh_id ='@wh_id@'
              and wrkare = @wrkare
              and wrkzon = '@wrkzon@'
              and oosflg = 0
    }
}
;

/* Create aisle if it is not created yet */
if ('@aisle_id@' <> '')
{
    [select 'x' from aisle where aisle_id = '@aisle_id@' and wh_id = '@wh_id@'] catch(-1403)
    |
    if (@? = -1403)
    {
        create aisle where wh_id = '@wh_id@' and aisle_id = '@aisle_id@'
    }
}