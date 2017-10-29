M1:
6138001	2 ÍÐ x 3
6175637	4 ÍÐ
6174423	6 ÍÐ
6175245	8 ÍÐ
6135800	10 ÍÐ

M2:
6138001	2 ÍÐ x 3
6175637	4 ÍÐ
6174423	6 ÍÐ
6175245	8 ÍÐ
6135800	10 ÍÐ

M4:
6138001	2 ÍÐ x 4
6175637	4 ÍÐ
6174423	6 ÍÐ
6175245	8 ÍÐ
6135800	10 ÍÐ

M6:
6138001	2 ÍÐ x 4
6175637	4 ÍÐ
6174423	6 ÍÐ
6175245	8 ÍÐ
6135800	10 ÍÐ


[select prtnum
   from prtmst_view pv
  where pv.prtnum in ('6174423', '6175245', '6135800')
    and rownum < 2
    and pv.wh_id = 'LR1']
|
[select arecod
   from aremst am
  where am.arecod in ('M1', 'M2', 'M3', 'M4', 'M5', 'M6')]
|
publish data
 where prtnum = @prtnum
   and loopcnt = 200
   and arecod = @arecod
|
do loop
 where count = @loopcnt
|
[select untqty untcas,
        prtnum,
        ftpcod
   from prtftp_dtl pd
  where pd.prtnum = @prtnum
    and uomcod = 'CS'
    and pd.prt_client_id = 'LEGO-CNRDC'
    and rownum < 2]
|
[select untqty palqty
   from prtftp_dtl pd
  where pd.prtnum = @prtnum
    and uomcod = 'PA'
    and pd.prt_client_id = 'LEGO-CNRDC'
    and rownum < 2]
|
[select stoloc
   from locmst
  where arecod = @arecod
    and locsts = 'E'
    and rownum < 2
    and sto_zone_id not in (select sto_zone_id
                              from sto_zone sz
                             where sz.sto_zone_cod like 'SZ-M%-DMG'
                               and sz.wh_id = 'LR1')]
|
generate next number
 where numcod = 'lodnum'
|
publish data
 where lodnum = @nxtnum
|
generate next number
 where numcod = 'subnum'
|
publish data
 where subnum = @nxtnum
|
generate next number
 where numcod = 'dtlnum'
|
publish data
 where dtlnum = @nxtnum
|
publish data
 where prtnum = @prtnum
   and wh_id = 'LR1'
   and lodnum = @lodnum
   and subnum = @subnum
   and dtlnum = @dtlnum
   and ftpcod = @ftpcod
   and prtnum = @prtnum
|
create inventory
 WHERE serial_count = null
   AND hld_flg = 0
   AND cstms_typ = ""
   AND lotnum = ""
   AND asset_id = ""
   AND dty_stmp_flg = 0
   AND prtnum = @prtnum
   AND dtlnum = @dtlnum
   AND dty_stmp_trk_flg = 0
   AND prt_client_id = "LEGO-CNRDC"
   AND load_attr1_flg = 0
   AND untcas = @untcas
   AND totalQuantity = null
   AND inb_supnum = null
   AND lpn_child = null
   AND inv_attr_int2 = null
   AND inv_attr_int1 = null
   AND last_pck_usr_id = ""
   AND inv_attr_int5 = null
   AND inv_attr_int4 = null
   AND ship_id = null
   AND displayErrorPopup = 0
   AND inv_attr_int3 = null
   AND scanned_qty = 0
   AND po_num = ""
   AND sub_lpn_tracked = null
   AND loducc = ""
   AND has_children = null
   AND wrkref_dtl = ""
   AND redetermineExpirationDate = null
   AND wrkref = ""
   AND cstms_stat = null
   AND bill_through_dte = null
   AND cstms_vat_cod = ""
   AND dscrp_reacod = null
   AND dsp_prtnum = ""
   AND lodtag = ""
   AND mvlflg = 0
   AND untqty = @palqty
   AND hldtyp = null
   AND lodnum = @lodnum
   AND user_id = "SAMNI"
   AND cnsg_flg = 0
   AND lbl_on_split = 0
   AND pckdte = null
   AND sub_asset_typ = null
   AND cstms_cmmdty_cod = ""
   AND exec_sts = null
   AND hldnum = ""
   AND inv_attr_str11 = ""
   AND inv_attr_str10 = ""
   AND components = null
   AND cstms_crncy = ""
   AND inv_attr_str13 = ""
   AND tagdev = ""
   AND inv_attr_str12 = ""
   AND inv_attr_dte2 = null
   AND inv_attr_str15 = ""
   AND inv_attr_dte1 = null
   AND inv_attr_str14 = ""
   AND inv_attr_str17 = ""
   AND inv_attr_str16 = ""
   AND asnFlg = null
   AND inv_attr_str18 = ""
   AND load_attr4_flg = 0
   AND prmflg = 0
   AND sub_lpn = null
   AND hldqty = null
   AND phyflg = 0
   AND no_loc_putaway = 0
   AND untpak = 0
   AND UCCDate = null
   AND lodwgt = 0
   AND sub_tagsts = ""
   AND lpnInUseFlag = null
   AND carcod = null
   AND catch_unttyp = null
   AND ins_user_id = ""
   AND reasonCode = null
   AND arecod = ""
   AND rcvdte = null
   AND scanned_ctch_qty = 0
   AND bundled_flg = 0
   AND serialNumbers = null
   AND lpn = @lodnum
   AND ordsln = ""
   AND pallet_load_seq = 0
   AND load_attr2_flg = 0
   AND alcflg = 0
   AND errorMsg = ""
   AND sup_lotnum = ""
   AND palpos = ""
   AND invlin = null
   AND phdflg = 0
   AND ftpcod = @ftpcod
   AND avg_unt_catch_qty = 0
   AND ovrrcptconf = 0
   AND displayPopup = 0
   AND inventoryLevel = ""
   AND cmpkey = ""
   AND ageProfileName = null
   AND cstms_cnsgnmnt_id = ""
   AND mvsflg = 0
   AND subtag = ""
   AND stoloc = @stoloc
   AND invnum = ""
   AND distro_flg = 0
   AND distro_palopn_flg = 0
   AND subucc = ""
   AND client_id = ""
   AND displayDeletePopup = 0
   AND idmflg = 0
   AND lod_tagsts = ""
   AND cstms_bond_flg = 0
   AND distro_id = ""
   AND subnum = @subnum
   AND supnum = ""
   AND cstms_cst = ""
   AND ctnflg = 0
   AND ship_line_id = ""
   AND stgflg = null
   AND mandte = null
   AND car_move_id = null
   AND subwgt = 0
   AND condcod = ""
   AND dflt_orgcod = ""
   AND inv_attr_flt1 = null
   AND distro_ctnopn_flg = 0
   AND inv_attr_flt2 = null
   AND inv_attr_flt3 = null
   AND catch_qty = 0
   AND load_untqty = 0
   AND ctnnum = null
   AND ordlin = ""
   AND revlvl = ""
   AND redermineStatus = null
   AND ser_num_cnt = null
   AND trknum = null
   AND invsts = "A"
   AND asset_typ = ""
   AND invsln = null
   AND lodlvl = "L"
   AND load_attr5_flg = 0
   AND serialized = null
   AND inv_attr_str1 = ""
   AND inv_attr_str2 = ""
   AND inv_attr_str3 = ""
   AND lodhgt = 0
   AND inv_attr_str4 = ""
   AND inv_attr_str5 = "310"
   AND inv_attr_str6 = ""
   AND inv_attr_str7 = ""
   AND lngdsc = ""
   AND inv_attr_str8 = ""
   AND inv_attr_str9 = ""
   AND rcvkey = ""
   AND ordqty = null
   AND deviceCode = ""
   AND rttn_id = ""
   AND expire_dte = null
   AND orgcod = "CN"
   AND stoloc_untqty = 0
   AND wh_id = "LR1"
   AND age_pflnam = ""
   AND fifdte = null
   AND comment = null
   AND ser_lvl = null
   AND load_attr3_flg = 0
   AND wh_id = "LR1"
   AND reasonCode = "LOSTFOUND"
   AND deviceCode = "NONE"
   AND keepInError = "false"
   AND dstloc = @stoloc
   AND srcloc = "PERM-ADJ-LOC"
   AND cstms_cnsgnmnt_id = ""
   
   
[select stoloc yloc
   from locmst
  where wh_id = 'LR1'
    and stoloc like 'SSM%'
    and useflg = 1]
|
[select distinct lodnum
   from inventory_view iv
  where iv.stoloc = @yloc
    and iv.wh_id = 'LR1'] catch(-1403)
|
if (@? = 0)
{
    move inventory
     where srclod = @lodnum
       and wh_id = 'LR1'
       and dstloc = 'PND-M2'
}

[select *
   from trlr
  where stoloc_wh_id = 'LR1'
    and yard_loc like 'DD%']
|
[delete
   from cur_trlr_act
  where wh_id = 'LR1'
    and trlr_id = @trlr_id]
|
move trailer
 WHERE trlr_id = @trlr_id
   AND yard_loc_wh_id = 'LR1'
   AND yard_loc = 'YD01'
   AND confirm_warning_flg = 0 

[select lm.arecod,
        mz.mov_zone_cod,
        sz.sto_zone_cod,
        pz.pck_zone_cod,
        count(distinct stoloc) loccnt
   from locmst lm,
        pck_zone pz,
        mov_zone mz,
        sto_zone sz
  where lm.pck_zone_id = pz.pck_zone_id
    and lm.mov_zone_id = mz.mov_zone_id
    and lm.sto_zone_id = sz.sto_zone_id
    and lm.wh_id = 'LR1'
    and lm.useflg = 1
  group by arecod,
        mov_zone_cod,
        sto_zone_cod,
        pck_zone_cod
  order by arecod,
        mov_zone_cod,
        sto_zone_cod,
        pck_zone_cod]
        
[select lm.arecod,
        mz.mov_zone_cod,
        sz.sto_zone_cod,
        pz.pck_zone_cod,
        stoloc
   from locmst lm,
        pck_zone pz,
        mov_zone mz,
        sto_zone sz
  where lm.pck_zone_id = pz.pck_zone_id
    and lm.mov_zone_id = mz.mov_zone_id
    and lm.sto_zone_id = sz.sto_zone_id
    and lm.wh_id = 'LR1'
    and lm.useflg = 1
    and ((lm.arecod = 'M1' and mz.mov_zone_cod = 'MZ-M3-RESV') or (lm.arecod = 'M1' and mz.mov_zone_cod = 'MZ-M5-RESV') or (lm.arecod = 'PICKFACE' and mz.mov_zone_cod = 'MZ-M3-RESV'))
  order by arecod,
        stoloc]
[select *
   from locmst
  where wh_id = 'LR1'
    and stoloc not like '1%'
    and stoloc not like '2%'
    and stoloc not like 'M%'
    and arecod in ('M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'PICKFACE')];
    
    
allocate wave web
 WHERE schbat = 'wave-vas-002'
   AND pcktyp = 'PICK-N-REPLEN-N-SHIP'
   AND bulk_pck_flg = 0
   AND pricod = '3'
   AND pcksts_uom = 'L,S,D'
   AND fraUomMarked = 'PC,CS,LA,PA'
   AND wh_id = 'LR1'
   AND imr_uom_list = 'PC,CS,LA,PA'
   AND consby = 'ship_id'
   AND dst_mov_zone_id = '10281'
   AND dstloc = ''
   AND rrlflg = 0
   AND manSeqWrkRelFlg = 0
   
   
[select distinct iv.lodnum,
        iv.subnum,
        iv.dtlnum
   from inventory_view iv
  where iv.wrkref in (select wrkref
                        from pckwrk_view pv
                       where pv.schbat = 'CN-270820171505-1')
    and iv.stoloc not like 'SSM%'
    and iv.stoloc like 'V%']
|
[select stoloc dstloc,
        lodnum id,
        lodlvl,
        seqnum
   from invmov
  where lodnum in (@lodnum, @subnum, @dtlnum)
  order by seqnum] catch(-1403)
|
if (@? = 0)
{
    if (@lodlvl = 'L')
    {
        publish data
         where srclod = @id
        |
        hide stack variable
         where name = 'subnum'
        |
        hide stack variable
         where name = 'dtlnum'
        |
        move inventory
         where wh_id = 'LR1'
           and dstloc = @dstloc
           and lodnum = @srclod
           and oprcod = 'TRN'
    }
    else if (@lodlvl = 'D')
    {
        [select distinct lodnum srclod
           from inventory_view iv
          where iv.dtlnum = @id]
        |
        [select 'x'
           from invmov
          where seqnum = @seqnum
            and lodnum = @id] catch(-1403)
        |
        hide stack variable
         where name = 'dtlnum'
        |
        hide stack variable
         where name = 'subnum'
        |
        if (@? = 0)
        {
            move inventory
             where wh_id = 'LR1'
               and dstloc = @dstloc
               and lodnum = @srclod
               and oprcod = 'TRN'
        }
    }
};


[select pv.srcloc,
        lm.trvseq,
        lm.sto_seq,
        lm.arecod,
        pv.prtnum,
        pv.pckqty,
        pv.pckdte
   from pckwrk_view pv,
        locmst lm
  where pv.srcloc = lm.stoloc
    and pv.wh_id = lm.wh_id
    and pckqty = appqty
    and last_pck_usr_id = 'HUJUN'
  order by pckdte desc]