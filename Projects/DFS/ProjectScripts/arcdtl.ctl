[ select count(*) row_count from arcdtl where
    arc_nam = '@arc_nam@' and seqnum = @seqnum@ ] | if (@row_count > 0) {
       [ update arcdtl set
          arc_nam = '@arc_nam@'
,          seqnum = @seqnum@
,          srtseq = to_number('@srtseq@')
,          arc_table = '@arc_table@'
,          list_cmd = '@list_cmd@'
,          post_arc_cmd = '@post_arc_cmd@'
,          action_on_dup = '@action_on_dup@'
             where  arc_nam = '@arc_nam@' and seqnum = @seqnum@ ] }
             else { [ insert into arcdtl
                      (arc_nam, seqnum, srtseq, arc_table, list_cmd, post_arc_cmd, action_on_dup)
                      VALUES
                      ('@arc_nam@', @seqnum@, to_number('@srtseq@'), '@arc_table@', '@list_cmd@', '@post_arc_cmd@', '@action_on_dup@') ] }
