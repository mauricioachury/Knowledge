[select min(h.alloc_search_id) alloc_search_id,
        search_path_typ,
        arecod,
        lodlvl,
        d.colnam,
        d.colval
   from alloc_search_hdr h,
        alloc_search_dtl d
  where h.alloc_search_id = d.alloc_search_id
    and h.bldg_id = 'Greenwich'
    and not exists(select 'x'
                     from alloc_search_hdr h2,
                          alloc_search_dtl d2
                    where h2.alloc_search_id = d2.alloc_search_id
                      and h2.bldg_id = 'Greenwich'
                      and h2.search_path_typ = h.search_path_typ
                      and h2.arecod = h.arecod
                      and h2.lodlvl = h.lodlvl
                      and not(d2.colnam = d.colnam and d2.colval = d.colval))
  group by search_path_typ,
        arecod,
        lodlvl,
        colnam,
        colval
 having (count(*) > 1)
  order by alloc_search_id,
        arecod,
        lodlvl,
        search_path_typ,
        d.colnam,
        d.colval]
|
[select h.alloc_search_id alloc_search_id_dup,
        search_path_typ,
        arecod,
        lodlvl,
        d.colnam,
        d.colval
   from alloc_search_hdr h,
        alloc_search_dtl d
  where h.alloc_search_id = d.alloc_search_id
    and h.bldg_id = 'Greenwich'
    and h.arecod = @arecod
    and h.search_path_typ = @search_path_typ
    and h.lodlvl = @lodlvl
    and d.colnam = @colnam
    and d.colval = @colval
    and h.alloc_search_id <> @alloc_search_id]
|
remove allocation search header
 where alloc_search_id = @alloc_search_id_dup