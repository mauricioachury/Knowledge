[ select count(*) row_count from aremst where
    arecod = '@arecod@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
       [ update aremst set
          arecod = '@arecod@'
,          wh_id = '@wh_id@'
,          bldg_id = '@bldg_id@'
,          sigflg = to_number('@sigflg@')
,          pckcod = '@pckcod@'
,          conflg = to_number('@conflg@')
,          loccod = '@loccod@'
,          fifflg = to_number('@fifflg@')
,          lodflg = to_number('@lodflg@')
,          subflg = to_number('@subflg@')
,          dtlflg = to_number('@dtlflg@')
,          praflg = to_number('@praflg@')
,          expflg = to_number('@expflg@')
,          rcv_dck_flg = to_number('@rcv_dck_flg@')
,          adjflg = to_number('@adjflg@')
,          stgflg = to_number('@stgflg@')
,          shpflg = to_number('@shpflg@')
,          wipflg = to_number('@wipflg@')
,          fwiflg = to_number('@fwiflg@')
,          cntflg = to_number('@cntflg@')
,          xdaflg = to_number('@xdaflg@')
,          icnflg = to_number('@icnflg@')
,          prd_stgflg = @prd_stgflg@
,          wip_supflg = to_number('@wip_supflg@')
,          wip_expflg = to_number('@wip_expflg@')
,          pdflg = to_number('@pdflg@')
,          shp_dck_flg = to_number('@shp_dck_flg@')
,          yrdflg = to_number('@yrdflg@')
,          rnwl_sto_flg = to_number('@rnwl_sto_flg@')
,          cnzcod = '@cnzcod@'
,          cnzamt = decode('@cnzamt@', '','', to_number('@cnzamt@'))
,          def_rplcfg_invsts = '@def_rplcfg_invsts@'
,          def_rplcfg_pctflg = decode('@def_rplcfg_pctflg@', '','', to_number('@def_rplcfg_pctflg@'))
,          def_rplcfg_maxunt = decode('@def_rplcfg_maxunt@', '','', to_number('@def_rplcfg_maxunt@'))
,          def_rplcfg_minunt = decode('@def_rplcfg_minunt@', '','', to_number('@def_rplcfg_minunt@'))
,          stoare_flg = @stoare_flg@
,          ctngrp = '@ctngrp@'
,          rdtflg = to_number('@rdtflg@')
,          autclr_prcare = to_number('@autclr_prcare@')
,          rcv_stgflg = to_number('@rcv_stgflg@')
,          prod_flg = to_number('@prod_flg@')
,          put_to_sto_flg = @put_to_sto_flg@
,          pck_to_sto_flg = @pck_to_sto_flg@
,          recalc_putaway = to_number('@recalc_putaway@')
,          lost_loc = '@lost_loc@'
,          lbl_on_split = to_number('@lbl_on_split@')
,          split_trn = to_number('@split_trn@')
,          con_pal_flg = to_number('@con_pal_flg@')
,          share_loc_flg = to_number('@share_loc_flg@')
,          pck_steal_flg = to_number('@pck_steal_flg@')
,          cmb_list_flg = @cmb_list_flg@
,          pck_exp_are = '@pck_exp_are@'
,          sto_trlr_flg = to_number('@sto_trlr_flg@')
,          bto_kit_dep_flg = @bto_kit_dep_flg@
,          shp_stg_ovrd_flg = @shp_stg_ovrd_flg@
,          ftl_flg = @ftl_flg@
,          prox_put_cod = '@prox_put_cod@'
,          start_pal_flg = @start_pal_flg@
,          dyn_slot_flg = @dyn_slot_flg@
,          dispatch_flg = @dispatch_flg@
,          dstr_flg = @dstr_flg@
,          dstr_pck_pal_flg = @dstr_pck_pal_flg@
,          dstr_pck_ctn_flg = @dstr_pck_ctn_flg@
,          dstr_sug_pal_flg = @dstr_sug_pal_flg@
,          dstr_sug_ctn_flg = @dstr_sug_ctn_flg@
,          dstr_excp_loc = '@dstr_excp_loc@'
,          moddte = sysdate
,          mod_usr_id = '@mod_usr_id@'
,          u_version = to_number('@u_version@')
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
,          cap_fill_flg = to_number('@cap_fill_flg@')
,          vc_cmplx_pckmtd = @vc_cmplx_pckmtd@
,          vc_inclod = @vc_inclod@
             where  arecod = '@arecod@' and wh_id = '@wh_id@' ] }
             else { [ insert into aremst
                      (arecod, wh_id, bldg_id, sigflg, pckcod, conflg, loccod, fifflg, lodflg, subflg, dtlflg, praflg, expflg, rcv_dck_flg, adjflg, stgflg, shpflg, wipflg, fwiflg, cntflg, xdaflg, icnflg, prd_stgflg, wip_supflg, wip_expflg, pdflg, shp_dck_flg, yrdflg, rnwl_sto_flg, cnzcod, cnzamt, def_rplcfg_invsts, def_rplcfg_pctflg, def_rplcfg_maxunt, def_rplcfg_minunt, stoare_flg, ctngrp, rdtflg, autclr_prcare, rcv_stgflg, prod_flg, put_to_sto_flg, pck_to_sto_flg, recalc_putaway, lost_loc, lbl_on_split, split_trn, con_pal_flg, share_loc_flg, pck_steal_flg, cmb_list_flg, pck_exp_are, sto_trlr_flg, bto_kit_dep_flg, shp_stg_ovrd_flg, ftl_flg, prox_put_cod, start_pal_flg, dyn_slot_flg, dispatch_flg, dstr_flg, dstr_pck_pal_flg, dstr_pck_ctn_flg, dstr_sug_pal_flg, dstr_sug_ctn_flg, dstr_excp_loc, moddte, mod_usr_id, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id, cap_fill_flg, vc_cmplx_pckmtd, vc_inclod)
                      VALUES
                      ('@arecod@', '@wh_id@', '@bldg_id@', to_number('@sigflg@'), '@pckcod@', to_number('@conflg@'), '@loccod@', to_number('@fifflg@'), to_number('@lodflg@'), to_number('@subflg@'), to_number('@dtlflg@'), to_number('@praflg@'), to_number('@expflg@'), to_number('@rcv_dck_flg@'), to_number('@adjflg@'), to_number('@stgflg@'), to_number('@shpflg@'), to_number('@wipflg@'), to_number('@fwiflg@'), to_number('@cntflg@'), to_number('@xdaflg@'), to_number('@icnflg@'), @prd_stgflg@, to_number('@wip_supflg@'), to_number('@wip_expflg@'), to_number('@pdflg@'), to_number('@shp_dck_flg@'), to_number('@yrdflg@'), to_number('@rnwl_sto_flg@'), '@cnzcod@', decode('@cnzamt@', '','', to_number('@cnzamt@')), '@def_rplcfg_invsts@', to_number('@def_rplcfg_pctflg@'), decode('@def_rplcfg_maxunt@', '','', to_number('@def_rplcfg_maxunt@')), decode('@def_rplcfg_minunt@', '','', to_number('@def_rplcfg_minunt@')), @stoare_flg@, '@ctngrp@', to_number('@rdtflg@'), to_number('@autclr_prcare@'), to_number('@rcv_stgflg@'), to_number('@prod_flg@'), @put_to_sto_flg@, @pck_to_sto_flg@, to_number('@recalc_putaway@'), '@lost_loc@', to_number('@lbl_on_split@'), to_number('@split_trn@'), to_number('@con_pal_flg@'), to_number('@share_loc_flg@'), to_number('@pck_steal_flg@'), @cmb_list_flg@, '@pck_exp_are@', to_number('@sto_trlr_flg@'), @bto_kit_dep_flg@, @shp_stg_ovrd_flg@, @ftl_flg@, '@prox_put_cod@', @start_pal_flg@, @dyn_slot_flg@, @dispatch_flg@, @dstr_flg@, @dstr_pck_pal_flg@, @dstr_pck_ctn_flg@, @dstr_sug_pal_flg@, @dstr_sug_ctn_flg@, '@dstr_excp_loc@', sysdate, '@mod_usr_id@', to_number('@u_version@'), sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@', to_number('@cap_fill_flg@'), @vc_cmplx_pckmtd@, @vc_inclod@) ] }
