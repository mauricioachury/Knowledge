/* This logic is for workflow of 'move inventory' when receive inventory into
* receiving stage for item assigned to layer picking face, when the layer qty
* on the received pallet is different with another ftpcod layer qty which is
* not picked yet, then put hold on it to make sure existing inventory all
* consumed before this new pallet allocatable.
*/
[select distinct iv.stoloc,
iv.prtnum,
iv.prt_client_id,
iv.ftpcod,
iv.wh_id,
iv.lodnum,
iv.dtlnum
from inventory_view iv
join locmst lm
on iv.stoloc = lm.stoloc
and iv.wh_id = lm.wh_id
join loc_typ lt
on lm.loc_typ_id = lt.loc_typ_id
and lm.wh_id = lt.wh_id
and lt.rcv_stgflg = 1
and iv.lodnum = @lodnum
where exists(select 'x'
from rplcfg r
join locmst lm
on r.stoloc = lm.stoloc
and r.wh_id = lm.wh_id
join pck_zone pz
on lm.pck_zone_id = pz.pck_zone_id
and lm.wh_id = pz.wh_id
join alloc_search_path_rule aspr
on pz.pck_zone_id = aspr.pck_zone_id
where aspr.uomcod = 'LA'
and r.prtnum = iv.prtnum
and r.prt_client_id = iv.prt_client_id
and r.wh_id = iv.wh_id
and rownum < 2)
and exists(select 'x'
from prtftp_dtl pr
join inventory_view it
on pr.prtnum = it.prtnum
and pr.prt_client_id = it.prt_client_id
and pr.wh_id = it.wh_id
and pr.ftpcod = iv.ftpcod
and pr.ftpcod <> it.ftpcod
join locmst lm
on it.stoloc = lm.stoloc
and it.wh_id = lm.wh_id
join loc_typ lt
on lm.loc_typ_id = lt.loc_typ_id
and lt.fwiflg = 1
join prtftp_dtl ps
on it.ftpcod = ps.ftpcod
and it.prtnum = ps.prtnum
and it.prt_client_id = ps.prt_client_id
and it.wh_id = ps.wh_id
where pr.layer_flg = 1
and ps.layer_flg = 1
and it.ship_line_id is null
and pr.untqty <> ps.untqty
and pr.prtnum = iv.prtnum
and pr.prt_client_id = iv.prt_client_id
and pr.wh_id = iv.wh_id)] catch(-1403)
|
if (@? = 0)
{
[select hldpfx,
hldnum,
reacod,
wh_id
from hldmst h
where hldnum = 'LAYQTY'
and hldpfx = @wh_id
and wh_id = @wh_id
and not exists (select 'x' from invhld i where i.hldnum = h.hldnum and i.hldpfx = h.hldpfx and i.wh_id = h.wh_id and i.dtlnum = @dtlnum)] catch(-1403)
|
if (@? = 0)
{
process inventory hold change
where acttyp = 'A'
and @+reacod
and prc_hldpfx = @hldpfx
and prc_hldnum = @hldnum
and wh_id = @wh_id
and onhold_Inv = 1
and usr_id = nvl(@usr_id,@@usr_id)
and dtlnum = @dtlnum
}
}