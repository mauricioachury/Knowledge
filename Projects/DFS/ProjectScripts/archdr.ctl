[ select count(*) row_count from archdr where
    arc_nam = '@arc_nam@' ] | if (@row_count > 0) {
       [ update archdr set
          arc_nam = '@arc_nam@'
,          arc_table = '@arc_table@'
,          list_cmd = '@list_cmd@'
,          max_rows = to_number('@max_rows@')
,          sts_fil = '@sts_fil@'
,          purge_flg = to_number('@purge_flg@')
,          post_arc_cmd = '@post_arc_cmd@'
,          action_on_dup = '@action_on_dup@'
             where  arc_nam = '@arc_nam@' ] }
             else { [ insert into archdr
                      (arc_nam, arc_table, list_cmd, max_rows, sts_fil, purge_flg, post_arc_cmd, action_on_dup)
                      VALUES
                      ('@arc_nam@', '@arc_table@', '@list_cmd@', to_number('@max_rows@'), '@sts_fil@', to_number('@purge_flg@'), '@post_arc_cmd@', '@action_on_dup@') ] }
