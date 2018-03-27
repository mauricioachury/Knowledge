#include <../../dcs/include/dcsddl.h>
#include <dcscolwid.h>
#include <dcstbldef.h>
#include <../../moca/include/sqlDataTypes.h>
#include <../../les/src/incsrc/varcolwid.h>

mset command on
[
ALTER_TABLE_ADD_COLUMN_BEGIN(prtmst, vc_maxqty_for_loc)
    INTEGER_TY null
ALTER_TABLE_ADD_COLUMN_END
] catch (ERR_COLUMN_ALREADY_EXISTS)
RUN_DDL
mset command off

mset command on

create db documentation
 where table = "prtmst"
   and vc_maxqty_for_loc =  "DFS Max Inventory Quantity for Location."
/
mset command off

mset command on

[
 DROP_VIEW(prtmst_view)
] catch(-204, -942, -3701)
RUN_DDL

mset command off

/*
 * This view will return everything from the prtmst
 * with the wh_id_tmpl renamed to wh_id.
 */

CREATE_VIEW(prtmst_view)
  select prtmst.*, 
         prtmst.wh_id_tmpl wh_id
  from prtmst
RUN_DDL

/* Update prtmst with time window
 */
mset command on

[select rtnum1 fifwin,
        rtstr1 prtfam
   from poldat p
  where p.polcod = 'VAR'
    and p.polvar = 'PWY-TIME-WINDOW'
    and p.polval = 'ITEM-FAMILY-AND-DAYS'
    and p.rtnum1 > 0] catch(-1403)
|
if (@? = 0)
{
    [update prtmst
        set dte_win_typ = 'F',
            timcod = 'D',
            fifwin = @fifwin
      where prtfam = @prtfam
        and dte_win_typ is null] catch(-1403)
};

RUN_SQL

/* Disable flag ctn_dstr_flg so Pre-D receiving will prompt user to scan
 * LPN other than CTN.
 */
/*mset command on

[update prtftp_dtl
    set ctn_dstr_flg = 0,
        last_upd_user_id ='SAMNI'
  where ctn_dstr_flg = 1] catch(-1403);

RUN_SQL
*/


/* Disable useflg for dedicate location but not assigned with SKU, these
 * locations will be manually turn on when assigning SKU to them.
 */
mset command on

[update locmst
    set useflg = 0
  where arecod in ('LQRD','LQRDC','VLQRD','VLQRDC','WIND',
                   'WINDC','VWIND','VWINDC','TOBD','TOBDC')
    and not exists (select 'x'
                      from rplcfg r
                     where r.stoloc = locmst.stoloc
                       and r.wh_id = locmst.wh_id)] catch(-1403);

RUN_SQL
mset command off

/* Disable useflg for some locations which will be considered to be used with
 * first level as one location.
 */
mset command on

[update locmst
    set useflg = 0
  where arecod in (select arecod
                     from aremst
                    where bldg_id = 'Greenwich'
                      and wh_id ='SGDC')
    and ((stoloc >= 'A02001' and stoloc <= 'A02040') or
         (stoloc >= 'B02001' and stoloc <= 'B02040') or
         (stoloc >= 'C02001' and stoloc <= 'C02040') or
         (stoloc >= 'D02001' and stoloc <= 'D02060') or
         (stoloc >= 'E02001' and stoloc <= 'E02020') or
         (stoloc >= 'E02041' and stoloc <= 'E02060') or
         (stoloc >= 'F02001' and stoloc <= 'F02017') or
         (stoloc >= 'G02001' and stoloc <= 'G02040') or
         (stoloc >= 'H02001' and stoloc <= 'H02040') or
         (stoloc >= 'I02001' and stoloc <= 'I02040') or
         (stoloc >= 'J02001' and stoloc <= 'J02040')
    and wh_id ='SGDC')] catch(-1403);

RUN_SQL
mset command off
