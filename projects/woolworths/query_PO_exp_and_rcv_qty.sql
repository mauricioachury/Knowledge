[select   to_char(rimhdr.invdte, 'yyyy-mm-dd') Order_Date,
            rimhdr.invnum,
            rimlin.prtnum,
            nvl(rimlin.expqty,0) expqty,
            nvl(rimlin.idnqty,0) rcvqty
       from rimhdr
       left join rimlin
         on rimhdr.invnum = rimlin.invnum
        and rimhdr.supnum = rimlin.supnum
        and rimhdr.client_id = rimlin.client_id
        and rimhdr.wh_id = rimlin.wh_id
       left join vc_prtdspuomqty_view prtview
         on prtview.prtnum = rimlin.prtnum
        and prtview.prt_client_id = rimlin.prt_client_id
        and prtview.wh_id = rimlin.wh_id
        and prtview.defftp_flg=1
      left join prtftp_dtl rcv_prtftp_dtl
        on rcv_prtftp_dtl.prtnum = prtview.prtnum
       and rcv_prtftp_dtl.prt_client_id = prtview.prt_client_id
       and rcv_prtftp_dtl.wh_id = prtview.wh_id
       and rcv_prtftp_dtl.ftpcod = prtview.ftpcod
       and rcv_prtftp_dtl.rcv_flg = 1
     where rimhdr.client_id = 'WOW' 
       and rimhdr.wh_id = 'SLDC'
and to_char(rimhdr.invdte, 'yyyy-mm-dd') = '2019-02-25'
  order by rimhdr.wh_id,
          rimhdr.client_id,
          rimhdr.supnum,
          rimhdr.invnum]
