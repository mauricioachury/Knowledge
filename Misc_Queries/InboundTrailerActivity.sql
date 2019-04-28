publish data
 where start_dt = '06/01/2018'
   and end_dt = '06/01/2018'
|
[select ta.trlr_stat trailer_status,
        dm.lngdsc activity,
        ta.lst_trndte activity_time,
        t.trknum
   from rcvtrk t
   join (select max(trndte) lst_trndte,
                trlr_stat,
                trknum
           from trlract
          group by trknum,
                trlr_stat
         union all
         select max(iv.lstdte) lst_trndte,
                'Pwy' trlr_stat,
                r.trknum
           from rcvinv r
           join rcvlin l
             on r.invnum = l.invnum
            and r.client_id = l.client_id
            and r.wh_id = l.wh_id
           join inventory_view iv
             on iv.rcvkey = l.rcvkey
           join locmst lm
             on iv.stoloc = lm.stoloc
           join loc_typ lt
             on lm.loc_typ_id = lt.loc_typ_id
            and lt.expflg <> 1
            and lt.rcv_stgflg <> 1
          group by r.trknum) ta
     on t.trknum = ta.trknum
   join (select colnam,
                colval,
                lngdsc
           from dscmst
         union all
         select 'rcvtrk_stat' colnam,
                'Pwy' colval,
                'Last Pallet Putaway' lngdsc
           from dual) dm
     on dm.colnam = 'rcvtrk_stat'
    and dm.colval = ta.trlr_stat
    and to_char(ta.lst_trndte, 'mm/dd/yyyy') >= @start_dt
    and to_char(ta.lst_trndte, 'mm/dd/yyyy') <= @end_dt
  order by trknum,
        lst_trndte]