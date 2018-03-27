if ('@entity@' = 'sto_bldg_seq')
{
  [delete
     from sto_bldg_seq
    where dst_bldg_id = 'Greenwich'
   ] catch(-1403)
}
else if ('@entity@' = 'dscmst')
{
  [delete
     from dscmst
    where colnam = 'arecod|wh_id'
      and colval = 'BTGLB|SGDC'
   ] catch(-1403)
}
else if ('@entity@' = 'aremst')
{
    [delete 
       from dscmst
      where colnam = 'arecod|wh_id'
        and colval in (select arecod || '|SGDC'
                         from aremst
                        where bldg_id = 'Greenwich')] catch(-1403)
    |
    [delete from aremst where bldg_id ='Greenwich'] catch(-1403);
}
else if ('@entity@' = 'storage_area')
{
  [select sto_area_id
     from sto_area_hdr
    where bldg_id = 'Greenwich'] catch(-1403)
  |
  if (@? = 0)
  {
      remove storage area header
       where sto_area_id = @sto_area_id
  }
}
else if ('@entity@' = 'allocation_search_path')
{
  [select alloc_search_id
     from alloc_search_hdr
    where bldg_id = 'Greenwich'
      and search_path_typ = 'PICK'] catch(-1403)
  |
  if (@? = 0)
  {
      remove allocation search header
       where alloc_search_id = @alloc_search_id
  }
}
else if ('@entity@' = 'move_path')
{
    [select srcare,
            dstare,
            lodlvl,
            wh_id
     from mov_path h
    where h.wh_id = 'SGDC'
      and h.ins_user_id = 'SAMNI'] catch(-1403)
    |
    if (@? = 0)
    {
        [delete from mov_path
          where srcare = @srcare
            and dstare = @dstare
            and lodlvl = @lodlvl
            and wh_id = @wh_id]
         |
         [delete from mov_path_dtl
          where srcare = @srcare
            and dstare = @dstare
            and lodlvl = @lodlvl
            and wh_id = @wh_id]
    }
}
else if ('@entity@' = 'work_area')
{
    [delete from dscmst
      where colnam ='wrkare|wh_id'
        and colval in (select wrkare||'|'||wh_id from wkamst where mod_usr_id = 'SAMNI')] catch(-1403)
    |
    [delete from wkamst where mod_usr_id = 'SAMNI'] catch(-1403)
}
else if ('@entity@' = 'work_zone')
{
    [delete from zonmst
      where ins_user_id = 'SAMNI'] catch(-1403)
}
else if ('@entity@' = 'rpl_allocation_search_path')
{
  [select alloc_search_id
     from alloc_search_hdr
    where bldg_id = 'Greenwich'
      and search_path_typ = 'RPL'] catch(-1403)
  |
  if (@? = 0)
  {
      remove allocation search header
       where alloc_search_id = @alloc_search_id
  }
}
else if ('@entity@' = 'rpl_path_cfg')
{
  [delete
     from rpl_path_cfg
    where ins_user_id = 'SAMNI'] catch(-1403)
}
else if ('@entity@' = 'poldat')
{
  [delete
     from poldat
    where mod_usr_id = 'SAMNI'
      and polcod in ('USR', 'VAR')] catch(-1403)
}
else if ('@entity@' = 'pcklst_lodlvl')
{
  [delete
     from pcklst_lodlvl
    where ins_user_id = 'SAMNI'
   ] catch(-1403)
}
else if ('@entity@' = 'release_rule_poldat')
{
  [delete
     from poldat
    where mod_usr_id = 'SAMNI'
      and polcod = 'PICK-RELEASE'
      and polvar = 'RELEASE-RULES'
   ] catch(-1403)
}
else if ('@entity@' = 'locmst_temp')
{
  [delete
     from locmst
    where ins_user_id = 'TEMP'
   ] catch(-1403)
}
else if ('@entity@' = 'rf_term_mst')
{
  [delete
     from rf_term_mst
    where ins_user_id = 'SAMNI'
   ] catch(-1403)
}
else if ('@entity@' = 'rf_locmst')
{
  [delete
     from locmst
    where ins_user_id = 'SAMNI'
      and arecod = 'RDTS'
   ] catch(-1403)
}
else if ('@entity@' = 'rftmst')
{
  [delete
     from rftmst
    where mod_usr_id = 'SAMNI'
      and hmewrkare in ('WKAGM','WKASWT')
   ] catch(-1403)
}
else if ('@entity@' = 'dev_wrkare')
{
  [delete
     from dev_wrkare
    where ins_user_id = 'SAMNI'
      and wrkare in ('WKAGM','WKASWT')
   ] catch(-1403)
}
else if ('@entity@' = 'devmst')
{
  [delete
     from devmst
    where ins_user_id = 'SAMNI'
   ] catch(-1403)
}
else if ('@entity@' = 'rplcfg')
{
  [update locmst
      set asgflg = 0
    where stoloc in (select stoloc
                       from rplcfg
                      where mod_usr_id = 'SAMNI')
      and asgflg = 1] catch(-1403)
  ;
  [delete
     from rplcfg
    where mod_usr_id = 'SAMNI'
   ] catch(-1403)
  ;
  [delete
     from poldat
    where polcod = 'STORE-ASG-LOC-STS-AFS'
      and mod_usr_id = 'SAMNI'] catch(-1403)
  ;
  [delete
     from poldat_hst
     where polcod = 'STORE-ASG-LOC-STS-AFS'
         and mod_usr_id = 'SAMNI'] catch(-1403)
}
else if ('@entity@' = 'job_definition')
{
  [delete
     from job_definition
    where job_id in ('TRIGGER-RPL')
   ] catch(-1403)
}
else if ('@entity@' = 'vehopr')
{
  [delete
     from vehopr
    where oprcod in ('CTN')
   ] catch(-1403)
}
else if ('@entity@' = 'are_pck_flg')
{
  [delete
     from are_pck_flg
    where ins_user_id in ('SAMNI')
   ] catch(-1403)
}
else if ('@entity@' = 'les_mls_cat')
{
  [delete
     from les_mls_cat
    where grp_nam in ('dfs_data')
      and mls_id like 'err93%'
   ] catch(-1403)
}
else if ('@entity@' = 'reltyp_cmd')
{
  [delete
     from reltyp_cmd
    where ins_user_id in ('SAMNI')
   ] catch(-1403)
}
else if ('@entity@' = 'archive')
{
  [delete
     from archdr
    where arc_nam in ('ALLOC-RULE-HDR','COMPLETED-COUNTS')
   ] catch(-1403)
  ;
  [delete
     from arcdtl
    where arc_nam in ('ALLOC-RULE-HDR','COMPLETED-COUNTS')] catch(-1403)
}
else if ('@entity@' = 'wh_serv_exitpnt_arecod')
{
  [delete
     from wh_serv_exitpnt_arecod
    where mod_usr_id in ('SAMNI')
   ] catch(-1403)
}
else if ('@entity@' = 'les_lkp')
{
  [delete
     from les_lkp
    where grp_nam in ('dfs_data')
   ] catch(-1403)
}
else if ('@entity@' = 'les_var_vp')
{
  [delete
     from les_var_vp
    where grp_nam in ('dfs_data')
   ] catch(-1403)
}
else if ('@entity@' = 'masterlocmst')
{
  [delete
     from locmst
    where arecod in (select arecod
                   from aremst
                  where bldg_id = 'Greenwich'
                    and wh_id = 'SGDC')
   ] catch(-1403)
  ;
  [delete
     from invlod
    where ins_user_id = 'SAMNI'
      and prmflg = 1
      and mvlflg = 0
 ] catch(-1403)
}
else if ('@entity@' = 'are_invmix_rule')
{
  [delete
     from are_invmix_rule
    where ins_user_id in ('SAMNI')
   ] catch(-1403)
}