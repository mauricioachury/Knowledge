/* This workflow will do:
 * 1. When layer picker setdown list pick into a movement zone of PNDLL/PNDLB,
 *    we assign this work to a dummy user so no one can pick it up.
*/
[select distinct iv.lodnum,
        iv.wh_id
  from inventory_view iv
  join locmst lm
    on iv.stoloc = lm.stoloc
   and iv.wh_id = lm.wh_id
  join loc_typ lt
    on lm.loc_typ_id = lt.loc_typ_id
   and lm.wh_id = lt.wh_id
   and lt.pdflg = 1
   and iv.lodnum = @lodnum] catch(-1403)
|
if (@? = 0)
{
    [select distinct q.reqnum
       from wrkque q
       join pckwrk_view pv
         on q.list_id = pv.list_id
        and q.wh_id = pv.wh_id
       join inventory_view iv
         on pv.wrkref = iv.wrkref
        and pv.wh_id = iv.wh_id
      where exists (select 'x'
                      from pckwrk_hdr ph
                     where ph.list_id = pv.list_id
                       and ph.pckqty > ph.appqty)
        and not exists(select 'x'
                         from pckwrk_hdr ph2
                        where ph2.list_id = pv.list_id
                          and ph2.pckqty > ph2.appqty
                          and ph2.pck_uom = 'LA')
        and iv.lodnum = @lodnum
        and iv.wh_id = @wh_id] catch(-1403)
     |
     if (@? = 0)
     {
         [update wrkque
             set asg_usr_id = 'DUMMY_PND_USER'
         where reqnum = @reqnum]
     }
}