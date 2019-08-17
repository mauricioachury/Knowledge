[ select count(*) row_count from job_definition where
    job_id = '@job_id@' ] | if (@row_count > 0) {
       [ update job_definition set
          job_id = '@job_id@'
,          role_id = '@role_id@'
,          name = '@name@'
,          enabled = @enabled@
,          type = '@type@'
,          command = '@command@'
,          log_file = '@log_file@'
,          trace_level = '@trace_level@'
,          overlap = @overlap@
,          schedule = '@schedule@'
,          start_delay = to_number('@start_delay@')
,          timer = to_number('@timer@')
,          grp_nam = '@grp_nam@'
             where  job_id = '@job_id@' ] }
             else { [ insert into job_definition
                      (job_id, role_id, name, enabled, type, command, log_file, trace_level, overlap, schedule, start_delay, timer, grp_nam)
                      VALUES
                      ('@job_id@', '@role_id@', '@name@', @enabled@, '@type@', '@command@', '@log_file@', '@trace_level@', @overlap@, '@schedule@', to_number('@start_delay@'), to_number('@timer@'), '@grp_nam@') ] }
;
[select 'x'
   from job_env_definition
  where job_id = 'USR-CREATE-DELAY-FOR-BREAK'
    and name = 'USR_ID'] catch(-1403)
|
if (@? = -1403)
{
    [ insert into job_env_definition
      (job_id, name, value)
    values
      ('USR-CREATE-DELAY-FOR-BREAK', 'USR_ID', 'SUPER')]
}