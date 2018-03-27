/*[select sto_area_id
 *   from sto_area_hdr
 *  where bldg_id = 'Greenwich']
 *|
 *remove storage area header
 * where sto_area_id = @sto_area_id
 * 
 * [select *
 *   from sto_area_hdr h,
 *        sto_area_dtl d
 *  where h.sto_area_id = d.sto_area_id
 *    and h.bldg_id = 'Greenwich'
 *   order by h.srtseq,
 *            d.colnam]
 */
[select count(*) row_count
   from sto_area_hdr
  where dstare = '@dstare@'
    and bldg_id = '@bldg_id@'
    and strategy = '@strategy@']
 |
 if (@row_count > 0)
 {
        if ('@prtfam@' is null and '@inv_attr_str1@' is null and '@invsts@' is null)
        {
            [select sto_area_id
             from sto_area_hdr
            where dstare = '@dstare@'
              and bldg_id = '@bldg_id@'
              and strategy = '@strategy@']
            |
            publish data
               where exists_flg = 1
                 and sto_area_id = @sto_area_id
        }
        else
        {
            [select sto_area_id
               from sto_area_dtl
              where colnam = 'prtfam'
                and colval = '@prtfam@'
                and exists (select 'x' from sto_area_hdr h
                             where h.sto_area_id = sto_area_dtl.sto_area_id
                               and h.dstare = '@dstare@'
                               and h.bldg_id = '@bldg_id@'
                               and h.strategy = '@strategy@')
                and (exists (select 'x' from sto_area_dtl d
                        where d.sto_area_id = sto_area_dtl.sto_area_id
                          and d.colnam = 'inv_attr_str1'
                          and d.colval = '@inv_attr_str1@')
                      or '@inv_attr_str1@' is null)
                and (exists (select 'x' from sto_area_dtl d
                        where d.sto_area_id = sto_area_dtl.sto_area_id
                          and d.colnam = 'invsts'
                          and d.colval = '@invsts@')
                      or '@invsts@' is null)] catch(-1403)
            |
            if (@? = 0 and @sto_area_id != '')
            {
               publish data
                 where exists_flg = 1
                   and sto_area_id = @sto_area_id
            }
        }
}
|
if ('@inv_attr_str1@' = '')
{
    hide stack variable
      where name = 'inv_attr_str1'
}
else
{
    publish data
      where inv_attr_str1 = '@inv_attr_str1@'
}
|
if ('@dept_cod@' = '')
{
    hide stack variable
      where name = 'dept_cod'
}
else
{
    publish data
      where dept_cod = '@dept_cod@'
}
|
if ('@prtfam@' = '')
{
    hide stack variable
      where name = 'prtfam'
}
else
{
    publish data
      where prtfam = '@prtfam@'
}
|
if ('@invsts@' = '')
{
    hide stack variable
      where name = 'invsts'
}
else
{
    publish data
      where invsts = '@invsts@'
}
|
if (@exists_flg = 1)
{
    change storage area
      where sto_area_id = @sto_area_id
        and wh_id = '@wh_id@'
        and bldg_id = '@bldg_id@'
        and dstare = '@dstare@'
        and strategy = '@strategy@'
        and @+prtfam
        and @+inv_attr_str1
        and @+dept_cod
        and @+invsts
}
else
{
    create storage area
        where wh_id = '@wh_id@'
          and bldg_id = '@bldg_id@'
          and dstare = '@dstare@'
          and strategy = '@strategy@'
          and srtseq = 9999
          and @+prtfam
          and @+inv_attr_str1
          and @+dept_cod
          and @+invsts
}
