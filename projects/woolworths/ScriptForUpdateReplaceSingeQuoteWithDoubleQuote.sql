[select pv.prtnum,
        pv.prt_client_id,
        pd.lngdsc old_lngdsc,
        pd.colnam,
        pd.colval
   from prtdsc pd,
        prtmst_view pv
  where pd.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
    and pd.colval = pv.prtnum || '|' || pv.prt_client_id || '|' || pv.wh_id
    and pd.lngdsc like '%''%'
    and rownum < 2]
|
[update prtdsc
    set lngdsc = replace(lngdsc, '''', '"')
  where colnam = @colnam
    and colval = @colval]
|
[select @old_lngdsc old_lngdsc,
        prtdsc.lngdsc,
        prtdsc.colnam,
        prtdsc.colval
   from prtdsc
  where colnam = @colnam
    and colval = @colval]