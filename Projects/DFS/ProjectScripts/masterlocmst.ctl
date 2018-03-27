[select length('@stos@') stolen
   from dual]
|
if (@stolen = 6)
{
    publish data
     where prefix = substr('@stos@', 1, 1)
       and lvl = substr('@stos@', 2, 2)
       and start = to_number(substr('@stos@', 4, 3))
       and end = to_number(substr('@stoe@', 4, 3))
}
else if (@stolen = 7)
{
    publish data
     where prefix = substr('@stos@', 1, 2)
       and lvl = substr('@stos@', 3, 2)
       and start = to_number(substr('@stos@', 5, 3))
       and end = to_number(substr('@stoe@', 5, 3))
}
|
do loop
 where count = @end - @start + 1
|
{
    [select @prefix || @lvl || lpad((@i + @start), 3, '0') stoloc
       from dual]
    |
    if ('@trvord@' = 'asc')
    {
        publish data
          where detseq = @start + @i
        |
        [select to_number('@bastrv@') + @detseq trvseq from dual]
    }
    else
    {
        [select max(stoloc) maxloc
          from locmst
         where stoloc like @prefix||@lvl||'%'
           and stoloc > '@stoe@'
           and arecod in (select arecod
                           from aremst
                          where bldg_id = 'Greenwich'
                            and wh_id = 'SGDC')]
        |
        [select decode(@maxloc, null, @end,
                decode(length(@maxloc), 6,
                to_number(substr(@maxloc, 4, 3)),
                to_number(substr(@maxloc, 5, 3)))) endseq from dual]
        |
        [select to_number('@bastrv@') + @endseq - @start - @i + 1 trvseq from dual]
    }
    |
    /* For Beauty area, travel sequence needs to be horizontally,
     * so to gap level by multipling 1000
     */
    if (@prefix >= 'AD' and @prefix <= 'AO')
    {
        [select @trvseq + to_number(@lvl) * 1000 trvseq
           from dual]
    }
    |
    publish data
     where stoloc = @stoloc
       and trvseq = @trvseq
}
|
[ select count(*) row_count from locmst where
    stoloc = @stoloc and wh_id = '@wh_id@' ]
| if (@row_count > 0)
  {
       [ update locmst set
           wh_id = '@wh_id@'
,          arecod = '@arecod@'
,          velzon = '@velzon@'
,          wrkzon = '@wrkzon@'
,          aisle_id = '@aisle_id@'
,          trvseq = @trvseq
,          rescod = '@rescod@'
,          lochgt = to_number('@lochgt@')
,          loclen = to_number('@loclen@')
,          locwid = to_number('@locwid@')
,          locvrc = '@locvrc@'
,          maxqvl = decode(curqvl + pndqvl, 0, @maxqvl@, maxqvl)
,          curqvl = decode(curqvl + pndqvl, 0, @curqvl@, curqvl)
,          pndqvl = decode(curqvl + pndqvl, 0, @pndqvl@, pndqvl)
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
             where  stoloc = @stoloc and wh_id = '@wh_id@']}
else {
   [ insert into locmst
        (stoloc, wh_id, arecod, locsts, velzon, wrkzon, aisle_id, trvseq, rescod, lochgt, loclen, locwid, locvrc, maxqvl, curqvl, pndqvl, trfpct, erfpct, useflg, stoflg, pckflg, repflg, asgflg, cipflg, cntseq, numcnt, abccod, cntdte, devcod, lokcod, locacc, voc_chkdgt, lstdte, lstcod, lst_usr_id, slotseq, perm_asgflg, cntzon_id, section, x, y, z, attr1, attr2, attr3, attr4, attr5, basepoint_id, top_left_x, top_left_y, top_right_x, top_right_y, bottom_left_x, bottom_left_y, bottom_right_x, bottom_right_y, border_pad, auto_mov_flg, slot_id, def_maxqvl, ignore_psh_flg, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id, cntbck_ena_flg, prdlin, stgloc)
        VALUES
        (@stoloc, '@wh_id@', '@arecod@', '@locsts@', '@velzon@', '@wrkzon@', '@aisle_id@', @trvseq, '@rescod@', to_number('@lochgt@'), to_number('@loclen@'), to_number('@locwid@'), '@locvrc@', @maxqvl@, @curqvl@, @pndqvl@, to_number('@trfpct@'), to_number('@erfpct@'), to_number('@useflg@'), to_number('@stoflg@'), to_number('@pckflg@'), to_number('@repflg@'), to_number('@asgflg@'), to_number('@cipflg@'), '@cntseq@', @numcnt@, '@abccod@', null, '@devcod@', '@lokcod@', '@locacc@', '@voc_chkdgt@', null, '@lstcod@', '@lst_usr_id@', '@slotseq@', to_number('@perm_asgflg@'), '@cntzon_id@', '@section@', '@x@', '@y@', '@z@', '@attr1@', '@attr2@', '@attr3@', '@attr4@', '@attr5@', '@basepoint_id@', to_number('@top_left_x@'), to_number('@top_left_y@'), to_number('@top_right_x@'), to_number('@top_right_y@'), to_number('@bottom_left_x@'), to_number('@bottom_left_y@'), to_number('@bottom_right_x@'), to_number('@bottom_right_y@'), to_number('@border_pad@'), @auto_mov_flg@, '@slot_id@', @def_maxqvl@, @ignore_psh_flg@, to_number('@u_version@'), sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@', to_number('@cntbck_ena_flg@'), '@prdlin@', '@stgloc@') ]
}
|
/* For dedicated picking location or Beauty area, we create permanent load */
if ('@arecod@' = 'LQRD' or
    '@arecod@' = 'LQRDC' or
    '@arecod@' = 'WIND' or
    '@arecod@' = 'WINDC' or
    '@arecod@' = 'VLQRD' or
    '@arecod@' = 'VLQRDC' or
    '@arecod@' = 'VWIND' or
    '@arecod@' = 'VWINDC' or
    '@arecod@' = 'TOBD' or
    '@arecod@' = 'TOBDC' or
    '@arecod@' = 'CD' or
    '@arecod@' = 'EL' or
    '@arecod@' = 'LN' or
    '@arecod@' = 'CQ' or
    '@arecod@' = 'GU' or
    '@arecod@' = 'GV' or
    '@arecod@' = 'CMD' or
    '@arecod@' = 'CWB' or
    '@arecod@' = 'KH' or
    '@arecod@' = 'CKB' or
    '@arecod@' = 'CTR' or
    '@arecod@' = 'CEB' or
    '@arecod@' = 'CLOO' or
    '@arecod@' = 'CTRD' or
    '@arecod@' = 'VS' or
    '@arecod@' = 'FRA' or
    '@arecod@' = 'HFRA' or
    '@arecod@' = 'GNRC' or
    '@arecod@' = 'GFT' or
    '@arecod@' = 'FC' or
    '@arecod@' = 'DPSG' or
    '@arecod@' = 'PRSG')
{
    publish data
      where perm_lodnum = 'LPN' || @stoloc
    |
    [select 'x'
       from invlod
      where lodnum = @perm_lodnum] catch(-1403)
    |
    if (@? = 0)
    {
        [update invlod
            set wh_id = '@wh_id@',
                stoloc = @stoloc,
                lodwgt = null,
                prmflg = 1,
                unkflg = 0,
                mvlflg = 0,
                adddte = sysdate,
                lstmov = sysdate,
                lstdte = sysdate,
                lstcod = null,
                lst_usr_id = 'SAMNI',
                loducc = null,
                uccdte = null,
                palpos = null,
                asset_typ = null,
                avg_unt_catch_qty = null,
                u_version = 1,
                ins_dt = sysdate,
                last_upd_dt = sysdate,
                ins_user_id = 'SAMNI',
                last_upd_user_id = 'SAMNI',
                lodtag = null,
                lod_tagsts = null,
                lodhgt = 0,
                bundled_flg = 0,
                distro_palopn_flg = 0
          where lodnum = @perm_lodnum]
    }
    else
    {
        [insert into invlod
         (lodnum, wh_id, stoloc, lodwgt, prmflg, unkflg, mvlflg, adddte, lstmov, lstdte, lstcod, lst_usr_id, loducc, uccdte, palpos, asset_typ, avg_unt_catch_qty, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id, lodtag, lod_tagsts, lodhgt, bundled_flg, distro_palopn_flg)
         values
         (@perm_lodnum, '@wh_id@', @stoloc, null, 1, 0, 0, sysdate, sysdate, sysdate, null, 'SAMNI', null, null, null, null, null, 1, sysdate, sysdate, 'SAMNI', 'SAMNI', null, null, 0, 0, 0)]
    }
}