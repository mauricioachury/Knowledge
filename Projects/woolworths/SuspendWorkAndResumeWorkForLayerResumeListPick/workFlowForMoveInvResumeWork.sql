/* This workflow will do:
 * 1. When hauler transfer LPN of resume list pick from PNDLL/PNDLB
 *    to CONL/CONB movement zone, we clear the assigned dummy user so it will
 *    be picked up by a voice user for continue picking.
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
      where q.oprcod = 'RLPCK'
        and q.asg_usr_id = 'DUMMY_PND_USER'
        and iv.lodnum = @lodnum
        and iv.wh_id = @wh_id] catch(-1403)
     |
     if (@? = 0)
     {
         [update wrkque
             set asg_usr_id = ''
         where reqnum = @reqnum]
     }
}