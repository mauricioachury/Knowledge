[select count(distinct lodnum) Pallet_Received
   from inventory_view iv,
           rcvlin r
 where iv.rcvkey = r.rcvkey
     and r.trknum in (select trknum from rcvtrk t where t.trlr_id in (
select r.evt_arg_val
  from sl_evt_data e,
           sl_evt_arg_data r
  where e.evt_id ='MASTER_RCPT_COMPLETE'
    and e.evt_data_seq = r.evt_data_seq
    and r.evt_arg_id ='TRLR_ID'
    and to_char(evt_dt,'yyyy-mm-dd hh24:mi:ss') >= '2018-07-03 13:30'
    and to_char(evt_dt,'yyyy-mm-dd hh24:mi:ss') <= '2018-07-03 23:30'
))]