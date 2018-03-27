[ select count(*) row_count from wrkopr where
    oprcod = '@oprcod@' and wh_id_tmpl = '@wh_id_tmpl@' ] | if (@row_count > 0) {
       [ update wrkopr set
          oprcod = '@oprcod@'
,          wh_id_tmpl = '@wh_id_tmpl@'
,          baspri = @baspri@
,          exptim = to_number('@exptim@')
,          escinc = to_number('@escinc@')
,          maxescpri = to_number('@maxescpri@')
,          begdaycod = '@begdaycod@'
,          begtim = to_date('@begtim@','YYYYMMDDHH24MISS')
,          enddaycod = '@enddaycod@'
,          endtim = to_date('@endtim@','YYYYMMDDHH24MISS')
,          use_src_flg = to_number('@use_src_flg@')
,          esc_cmd_flg = to_number('@esc_cmd_flg@')
,          esc_cmd = '@esc_cmd@'
,          rls_cmd = '@rls_cmd@'
,          init_sts = '@init_sts@'
,          force_ack_loc_flg = to_number('@force_ack_loc_flg@')
             where  oprcod = '@oprcod@' and wh_id_tmpl = '@wh_id_tmpl@' ] }
             else { [ insert into wrkopr
                      (oprcod, wh_id_tmpl, baspri, exptim, escinc, maxescpri, begdaycod, begtim, enddaycod, endtim, use_src_flg, esc_cmd_flg, esc_cmd, rls_cmd, init_sts, force_ack_loc_flg)
                      VALUES
                      ('@oprcod@', '@wh_id_tmpl@', @baspri@, to_number('@exptim@'), to_number('@escinc@'), to_number('@maxescpri@'), '@begdaycod@', to_date('@begtim@','YYYYMMDDHH24MISS'), '@enddaycod@', to_date('@endtim@','YYYYMMDDHH24MISS'), to_number('@use_src_flg@'), to_number('@esc_cmd_flg@'), '@esc_cmd@', '@rls_cmd@', '@init_sts@', to_number('@force_ack_loc_flg@')) ] }
