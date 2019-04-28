<command>
<name>complete orphane putaway work</name>
<description>Complete Orphane Putaway Work</description>
<type>Local Syntax</type>
<local-syntax>
<![CDATA[
[select lm.stoloc,
        lm.wh_id
   from locmst lm
join loc_typ lt
on lm.loc_typ_id = lt.loc_typ_id
where lt.rcv_stgflg = 1]
|
[select @stoloc, @wh_id, ((select count (1) 
    from wrkque
    where srcloc = @stoloc
    and wh_id = @wh_id
	and oprcod = 'PUTDIR' 
    and wrksts in ('PEND')) -
(select count (1) 
    from invlod
    where stoloc=@stoloc
    and wh_id = @wh_id)) countdiff from dual]
|
if(@countdiff > 0) {
  publish data where countdiff = int(@countdiff)
  |
  [select reqnum, 'nomove' prcmod 
    from wrkque 
	where srcloc=@stoloc 
	and wh_id=@wh_id 
	and wrksts in ('PEND') 
	and oprcod='PUTDIR' 
	and rownum <= @countdiff]
  |
  complete  work where reqnum=@reqnum and prcmod=@prcmod
}
]]>
</local-syntax>
<documentation>

<remarks>
<![CDATA[
  <p>
  This complete the putaway work which is no more required as 
  user performed indirect putaway of the inventory from the 
  staging location.
  </p>
]]>
</remarks>
</documentation>
</command>