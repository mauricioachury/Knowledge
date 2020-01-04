[ select count(*) row_count from dscmst where
    colnam = '@colnam@' and colval = '@colval@' and locale_id = '@locale_id@' ] | if (@row_count > 0) {
       [ update dscmst set
          colnam = '@colnam@'
,          colval = '@colval@'
,          locale_id = '@locale_id@'
,          lngdsc = '@lngdsc@'
,          short_dsc = '@short_dsc@'
,          grp_nam = '@grp_nam@'
,          dtype = '@dtype@'
             where  colnam = '@colnam@' and colval = '@colval@' and locale_id = '@locale_id@' ] }
             else { [ insert into dscmst
                      (colnam, colval, locale_id, lngdsc, short_dsc, grp_nam, dtype)
                      VALUES
                      ('@colnam@', '@colval@', '@locale_id@', '@lngdsc@', '@short_dsc@', '@grp_nam@', '@dtype@') ] }
