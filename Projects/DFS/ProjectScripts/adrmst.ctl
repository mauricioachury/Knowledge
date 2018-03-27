[ select count(*) row_count from adrmst where
    adrnam = '@adrnam@' ] | if (@row_count > 0) {
       [ update adrmst set
           client_id = '@client_id@'
,          host_ext_id = '@host_ext_id@'
,          adrnam = '@adrnam@'
,          adrtyp = '@adrtyp@'
,          adrln1 = '@adrln1@'
,          adrln2 = '@adrln2@'
,          adrln3 = '@adrln3@'
,          adrcty = '@adrcty@'
,          adrstc = '@adrstc@'
,          adrpsz = '@adrpsz@'
,          ctry_name = '@ctry_name@'
,          rgncod = '@rgncod@'
,          phnnum = '@phnnum@'
,          faxnum = '@faxnum@'
,          attn_name = '@attn_name@'
,          attn_tel = '@attn_tel@'
,          cont_name = '@cont_name@'
,          cont_tel = '@cont_tel@'
,          cont_title = '@cont_title@'
,          rsaflg = to_number('@rsaflg@')
,          temp_flg = to_number('@temp_flg@')
,          po_box_flg = to_number('@po_box_flg@')
,          last_name = '@last_name@'
,          first_name = '@first_name@'
,          honorific = '@honorific@'
,          usr_dsp = '@usr_dsp@'
,          adr_district = '@adr_district@'
,          web_adr = '@web_adr@'
,          email_adr = '@email_adr@'
,          pagnum = '@pagnum@'
,          locale_id = '@locale_id@'
,          pool_flg = to_number('@pool_flg@')
,          pool_rate_serv_nam = '@pool_rate_serv_nam@'
,          ship_phnnum = '@ship_phnnum@'
,          ship_faxnum = '@ship_faxnum@'
,          ship_web_adr = '@ship_web_adr@'
,          ship_email_adr = '@ship_email_adr@'
,          ship_cont_name = '@ship_cont_name@'
,          ship_cont_title = '@ship_cont_title@'
,          ship_cont_tel = '@ship_cont_tel@'
,          ship_attn_name = '@ship_attn_name@'
,          ship_attn_phnnum = '@ship_attn_phnnum@'
,          tim_zon_cd = '@tim_zon_cd@'
,          rqst_state_cod = '@rqst_state_cod@'
,          grp_nam = '@grp_nam@'
,          latitude = '@latitude@'
,          longitude = '@longitude@'
,          gln = '@gln@'
,          cstms_site_typ = '@cstms_site_typ@'
,          cstms_tx_site = '@cstms_tx_site@'
             where  adrnam = '@adrnam@' ] }
             else { 
generate next number where numcod = 'adr_id'
|
publish data where adr_id = @nxtnum
|
[ insert into adrmst
                      (adr_id, client_id, host_ext_id, adrnam, adrtyp, adrln1, adrln2, adrln3, adrcty, adrstc, adrpsz, ctry_name, rgncod, phnnum, faxnum, attn_name, attn_tel, cont_name, cont_tel, cont_title, rsaflg, temp_flg, po_box_flg, last_name, first_name, honorific, usr_dsp, adr_district, web_adr, email_adr, pagnum, locale_id, pool_flg, pool_rate_serv_nam, ship_phnnum, ship_faxnum, ship_web_adr, ship_email_adr, ship_cont_name, ship_cont_title, ship_cont_tel, ship_attn_name, ship_attn_phnnum, tim_zon_cd, rqst_state_cod, grp_nam, latitude, longitude, gln, cstms_site_typ, cstms_tx_site)
                      VALUES
                      (@adr_id, '@client_id@', '@host_ext_id@', '@adrnam@', '@adrtyp@', '@adrln1@', '@adrln2@', '@adrln3@', '@adrcty@', '@adrstc@', '@adrpsz@', '@ctry_name@', '@rgncod@', '@phnnum@', '@faxnum@', '@attn_name@', '@attn_tel@', '@cont_name@', '@cont_tel@', '@cont_title@', to_number('@rsaflg@'), to_number('@temp_flg@'), to_number('@po_box_flg@'), '@last_name@', '@first_name@', '@honorific@', '@usr_dsp@', '@adr_district@', '@web_adr@', '@email_adr@', '@pagnum@', '@locale_id@', to_number('@pool_flg@'), '@pool_rate_serv_nam@', '@ship_phnnum@', '@ship_faxnum@', '@ship_web_adr@', '@ship_email_adr@', '@ship_cont_name@', '@ship_cont_title@', '@ship_cont_tel@', '@ship_attn_name@', '@ship_attn_phnnum@', '@tim_zon_cd@', '@rqst_state_cod@', '@grp_nam@', '@latitude@', '@longitude@', '@gln@', '@cstms_site_typ@', '@cstms_tx_site@') ] }
