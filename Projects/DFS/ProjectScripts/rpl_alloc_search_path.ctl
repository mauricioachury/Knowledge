/*[select alloc_search_id
 *   from alloc_search_hdr
 *  where bldg_id = 'Greenwich']
 *|
 *remove allocation search header
 * where alloc_search_id = @alloc_search_id
 */
[select count(*) row_count
   from alloc_search_hdr
  where arecod = '@arecod@'
    and search_path_typ = '@search_path_typ@'
    and lodlvl = '@lodlvl@']
 |
 if (@row_count > 0)
 {
        if ('@prtfam@' is null and '@dstare@' is null)
        {
            [select alloc_search_id
               from alloc_search_hdr
              where arecod = '@arecod@'
                and search_path_typ = '@search_path_typ@'
                and lodlvl = '@lodlvl@']
            |
            publish data
               where exists_flg = 1
                 and alloc_search_id = @alloc_search_id
        }
        else
        {
            [select alloc_search_id
               from alloc_search_dtl
              where colnam = 'prtfam'
                and colval = '@prtfam@'
                and exists (select 'x' from alloc_search_hdr h
                             where h.alloc_search_id = alloc_search_dtl.alloc_search_id
                               and h.arecod = '@arecod@'
                               and h.search_path_typ = '@search_path_typ@'
                               and h.lodlvl = '@lodlvl@')
                and (exists (select 'x' from alloc_search_dtl d
                        where d.alloc_search_id = alloc_search_dtl.alloc_search_id
                          and d.colnam = 'dstare'
                          and d.colval = '@dstare@')
                      or '@dstare@' is null)] catch(-1403)
            |
            if (@? = 0 and @alloc_search_id != '')
            {
               publish data
                 where exists_flg = 1
                   and alloc_search_id = @alloc_search_id
            }
        }
}
|
if ('@inv_attr_str1@' != '')
{
    publish data
      where inv_attr_str1 = '@inv_attr_str1@'
}
|
if (@exists_flg = 1)
{
    change allocation search header
      where alloc_search_id = @alloc_search_id
        and wh_id = '@wh_id@'
        and bldg_id = '@bldg_id@'
        and arecod = '@arecod@'
        and lodlvl = '@lodlvl@'
        and uomcod = '@uomcod@'
        and search_path_typ = '@search_path_typ@'
        and prtfam = '@prtfam@'
        and dstare = '@dstare@'
        and @+inv_attr_str1
}
else
{
    create allocation search path
        where wh_id = '@wh_id@'
          and bldg_id = '@bldg_id@'
          and arecod = '@arecod@'
          and lodlvl = '@lodlvl@'
          and uomcod = '@uomcod@'
          and srtseq = 9999
          and thresh_flg = 0
          and search_path_typ = '@search_path_typ@'
          and prtfam = '@prtfam@'
          and dstare = '@dstare@'
          and @+inv_attr_str1
}
