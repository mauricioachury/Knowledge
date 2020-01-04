[select to_char(q.cmpdte, 'yyyy-mm-dd') "Date",
        q.effpri "Priority",
        count(*) "Completed Count",
        d.totday_cmpcnt "Completed Count by Day",
        round(count(*) *100 / d.totday_cmpcnt, 2) "Percentage"
   from wrkhst q
   join (select to_char(cmpdte, 'yyyy-mm-dd') complete_date,
                count(*) totday_cmpcnt
           from wrkhst
          where oprcod in ('PIARPL', 'PRP')
          group by to_char(cmpdte, 'yyyy-mm-dd')) d
     on to_char(q.cmpdte, 'yyyy-mm-dd') = d.complete_date
  where q.oprcod in ('PIARPL', 'PRP')
  group by q.effpri,
        to_char(q.cmpdte, 'yyyy-mm-dd'),
        d.totday_cmpcnt
  order by to_char(q.cmpdte, 'yyyy-mm-dd'),
        effpri]

/* pick short analysis */
                publish data
                where start_date = '2019-12-12'
                  and stoloc = 'BN1431'
               |
               [select count(*) cnt,
                       cp.srcloc,
                       cp.prtnum,
                       cp.prt_client_id,
                       cp.wh_id
                  from canpck cp
                  join rplcfg r
                    on cp.srcloc = r.stoloc
                   and cp.wh_id = r.wh_id
                 where to_char(cp.candte, 'yyyy-mm-dd') = @start_date
                   and @+cp.srcloc^stoloc
                 group by cp.srcloc,
                       cp.prtnum,
                       cp.prt_client_id,
                       cp.wh_id
                having count(*) > 5
                 order by cnt desc]
               |
               [select tmp.*,
                       r.minunt
                  from (select srcloc,
                               prtnum,
                               pckqty,
                               adddte act_time,
                               adddte record_time,
                               pv.ins_user_id act_by,
                               'Add Pick' action,
                               'Adding pick for shipment line:' || pv.ship_line_id msg
                          from pckwrk_view pv
                         where pv.srcloc = @srcloc
                           and to_char(pv.adddte, 'yyyy-mm-dd') = @start_date
                        union all
                        select srcloc,
                               prtnum,
                               pckqty,
                               pv.pckdte act_time,
                               pv.adddte record_time,
                               pv.last_pck_usr_id act_by,
                               'Picking' action,
                               'Picking for shipment line:' || pv.ship_line_id msg
                          from pckwrk_view pv
                         where pv.srcloc = @srcloc
                           and to_char(pv.pckdte, 'yyyy-mm-dd') = @start_date
                        union all
                        select srcloc,
                               prtnum,
                               pckqty,
                               candte act_time,
                               cp.adddte record_time,
                               cp.can_usr_id act_by,
                               'Cancel Pick' action,
                               'Cancel pick for shipment line:' || cp.ship_line_id msg
                          from canpck cp
                         where cp.srcloc = @srcloc
                           and to_char(cp.candte, 'yyyy-mm-dd') = @start_date
                        union all
                        select @srcloc srcloc,
                               prtnum,
                               pckqty,
                               candte act_time,
                               adddte record_time,
                               cs.can_usr_id act_by,
                               'Cancel Short' action,
                               'Cancel short for shipment line:' || cs.ship_line_id msg
                          from canshort cs
                         where to_char(cs.candte, 'yyyy-mm-dd') = @start_date
                           and cs.prtnum = @prtnum
                           and cs.prt_client_id = @prt_client_id
                           and cs.wh_id = @wh_id
                        union all
                        select tostol srcloc,
                               prtnum,
                               trnqty pckqty,
                               dt.trndte act_time,
                               dt.trndte record_time,
                               decode(dt.usr_id || '|' || dt.actcod, 'UNKNOWN|RPLUNLCK', 'UNLOCK_JOB', 'UNKNOWN|RPLPRISETUP', 'PRIORITY_SETUP_JOB', dt.usr_id) act_by,
                               dt.oprcod || '|' || dt.actcod action,
                               decode(dt.actcod, 'PALRPL', 'Pallet Replenishing location', dt.fr_value || '|' || dt.to_value) msg
                          from dlytrn dt
                         where dt.tostol = @srcloc
                           and to_char(dt.trndte, 'yyyy-mm-dd') = @start_date) tmp
                  join rplcfg r
                    on tmp.prtnum = r.prtnum
                   and tmp.srcloc = r.stoloc
                 order by act_time]