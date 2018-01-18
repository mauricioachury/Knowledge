1. command for checking menu:
get addon_id catch(-1403) | list mtf menu config    where usr_id = 'SAMNI'      and locale_id = 'US_ENGLISH'      and mnu_grp = 'mtfmnuDeppckLst'       and opt_typ = 'O' 

2. expended sql:
[select les_mnu_itm.mnu_itm,
        les_mnu_itm.mnu_grp,
        options.itm_img_id,
        options.pmsn_mask,
        options.opt_typ,
        options.exec_parm,
        options.exec_nam,
        les_mnu_itm.mnu_seq itm_mnu_seq,
        options.opt_nam,
        sdm.mls_text itm_desc
   from les_mnu_itm
   left outer
   join (select colval,
                mls_text
           from sys_dsc_mst
          where locale_id = 'US_ENGLISH'
            and sys_dsc_mst.colnam = 'mnu_itm'
            and cust_lvl = (select max(cust_lvl) cust_lvl
                              from sys_dsc_mst s
                             where s.colnam = sys_dsc_mst.colnam
                               and s.colval = sys_dsc_mst.colval
                               and s.locale_id = sys_dsc_mst.locale_id)) sdm
     on (les_mnu_itm.mnu_itm = sdm.colval),
        (select les_mnu_opt.opt_nam,
                les_mnu_opt.btn_img_id itm_img_id,
                -1 pmsn_mask,
                les_mnu_opt.opt_typ,
                les_mnu_opt.exec_parm,
                les_mnu_opt.exec_nam
           from les_mnu_opt
          where les_mnu_opt.ena_flg != 0
            and les_mnu_opt.opt_typ = 'O'
            and (les_mnu_opt.addon_id is null or les_mnu_opt.addon_id = 'WM,SEAMLES')) options
  where les_mnu_itm.opt_nam = options.opt_nam
    and les_mnu_itm.mnu_grp = 'mtfmnuDeppckLst'
  order by les_mnu_itm.mnu_grp,
        les_mnu_itm.mnu_itm]
[select *
   from les_mnu_itm
  where les_mnu_itm.mnu_grp = 'mtfmnuDeppckLst']
[select *
   from les_mnu_opt
  where opt_nam in ('mtfoptDepSetDown', 'mtfoptDepVehFull')]

3. Go to 'Authorization Maintenance'-> Menu Option Maintenance -> Find option 'mtfoptDepSetDown' with option Name -> set Enabled flag with false.