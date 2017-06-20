#use $DCSDIR/include
#include <dcsddl.h>
#include <dcscolwid.h>
#include <dcstbldef.h>
#use $MOCADIR/include
#include <sqlDataTypes.h>
#use $LESDIR/include
#include <varcolwid.h>

mset command on

[CREATE_TABLE(var_totmov)
(
  wh_id   STRING_TY(32) not null,
	mv_id     STRING_TY(30) not null,
	lodnum     STRING_TY(20) not null,
	ordnum     STRING_TY(20),
	wrkref     STRING_TY(10),
	wrktyp     STRING_TY(3),
	devcod     STRING_TY(20) not null,
	srcloc     STRING_TY(20) not null,
	dstloc     STRING_TY(20) not null,
	dst_wrkzon STRING_TY(10) not null,
	wcs_dest_id STRING_TY(10) not null,
	ins_dt     DATE_TY not null,
	oub_log_dt     DATE_TY,
	inb_log_dt     DATE_TY,
	ins_user_id STRING_TY(40) not null,
	errcod     STRING_TY(20),
	errmsg     STRING_TY(20),
	err_dt     DATE_TY,
	err_ordsts STRING_TY(20),
	cmp_dt     DATE_TY,
	wrk_stn_id STRING_TY(30)
)]catch (ERR_TABLE_ALREADY_EXISTS)

RUN_DDL

[CREATE_PK_CONSTRAINT_BEGIN(var_totmov, var_totmov_pk)
(
  mv_id, lodnum, wh_id
)
CREATE_PK_CONSTRAINT_END] catch(ERR_PRIMARY_KEY_ALREADY_EXISTS) 

RUN_DDL

create db documentation
   where table = "var_totmov"
     and table_comment = "This table is used to store the movement information for a tote."
     and wh_id  = "Warehouse ID - the warehouse ID where the inventory will be moved to."
     and mv_id = "This is a system generated ID to represent a movement for one tote, or multiple totes for same order."
     and lodnum = "Is acutally tote ID, which is a permanent load."
     and ordnum = "For which order the inventory in this tote is."
     and wrkref = "wrkref for which this tote picked."
     and wrktyp = "Work type of the wrkwrk for which this tote picked."
     and devcod = "Device code from which dropped the tote."
     and srcloc = "Source location from where this tote moved from."
     and dstloc = "Destination location to where the tote moved."
     and dst_wrkzon = "Destination work zone of dstloc."
     and wcs_dest_id = "To where WCS should deliver this tote to, possible values are:PACK, SPLIT, KIT, CONSOL, SHIP."
     and ins_dt = "Record insert date."
     and oub_log_dt = "When this record gets outbound logged from WMS to WCS."
     and inb_log_dt = "When this record gets inbound logged from WCS to WMS."
     and ins_user_id = "User who inserted this record."
     and errcod = "Error code when processing inbound log event(from WCS)."
     and errmsg = "Error message when processing inbound log event(from WCS)."
     and err_dt = "Time when an error happened."
     and err_ordsts = "Order status when error happened, possible values are: COMPLETED, SORTED(from WCS)."
     and cmp_dt = "The completion date for delivering to destination."
     and wrk_stn_id = "Work station ID tracked in WCS(from WCS)."

RUN_DDL

mset command off