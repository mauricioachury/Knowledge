[ select count(*) row_count from bldg_mst where
    bldg_id = '@bldg_id@' and wh_id = '@wh_id@' ] | if (@row_count > 0) {
[select adr_id from adrmst where adrnam = '@adrnam@']
|       
[ update bldg_mst set
          bldg_id = '@bldg_id@'
,          wh_id = '@wh_id@'
,          business_unt = '@business_unt@'
,          adr_id = @adr_id
,          fluid_load_flg = to_number('@fluid_load_flg@')
,          sort_attr_locsts = '@sort_attr_locsts@'
,          sort_default_flg = to_number('@sort_default_flg@')
,          u_version = to_number('@u_version@')
,          ins_dt = sysdate
,          last_upd_dt = sysdate
,          ins_user_id = '@ins_user_id@'
,          last_upd_user_id = '@last_upd_user_id@'
             where  bldg_id = '@bldg_id@' and wh_id = '@wh_id@' ] }
             else { 
[select adr_id from adrmst where adrnam = '@adrnam@']
|
[ insert into bldg_mst
                      (bldg_id, wh_id, business_unt, adr_id, fluid_load_flg, sort_attr_locsts, sort_default_flg, u_version, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id)
                      VALUES
                      ('@bldg_id@', '@wh_id@', '@business_unt@', @adr_id, to_number('@fluid_load_flg@'), '@sort_attr_locsts@', to_number('@sort_default_flg@'), to_number('@u_version@'),sysdate, sysdate, '@ins_user_id@', '@last_upd_user_id@') ] }
