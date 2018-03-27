[select round(sum(p.pckqty / p.untcas)) cases_to_pick,
        round(sum(p.appqty / p.untcas)) cases_picked,
        round(sum(p.appqty / p.untcas) / sum(p.pckqty / p.untcas) * 100, 2) || '%' Pick_Completed,
        count(distinct o.ordnum) ordcnt,
        to_char(o.cpodte, 'yyyy-mm-dd') cpdte
   from pckwrk p,
        ord o
  where p.ordnum = o.ordnum
    and p.wrktyp = 'P'
    and p.adddte > sysdate -14
  group by to_char(o.cpodte, 'yyyy-mm-dd')
 having (round(sum(p.appqty / p.untcas) / sum(p.pckqty / p.untcas) * 100, 2) < 100)
  order by cpdte]
[select to_char(o.cpodte, 'yyyy-mm-dd') cpd,
        o.ordnum,
        p.prtnum,
        p.pckqty,
        p.appqty
   from pckwrk p,
        ord o
  where to_char(o.cpodte, 'yyyy-mm-dd') = '2018-03-16'
    and p.ordnum = o.ordnum
   and p.pckqty > p.appqty
   and p.wrktyp = 'P'
 order by cpd]