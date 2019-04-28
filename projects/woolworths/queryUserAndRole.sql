publish data
 where usr_id = '9849'
|
[select uv.usr_id,
        uv.login_id,
        uv.first_name,
        uv.last_name,
        decode(uv.super_usr_flg, 1, 'Yes', 'No') super_user,
        decode(uv.usr_sts, 'A', 'Active', 'E', 'Expired', 'I', 'Inactive') status,
        to_char(uv.moddte, 'yyyy/mm/dd') last_modified_dte,
        uv.mod_usr_id last_modified_by
   from users_view uv
  where @+usr_id
  order by usr_id]
|
[select role_id
   from les_usr_role ur
  where ur.usr_id = @usr_id] catch(-1403) >> res
|
convert column results to string
 where colnam = 'role_id'
   and res = @res
   and separator = ',    '
|
publish data
 where roles = @result_string
|
publish data
 where usr_id = @usr_id
   and login = @login_id
   and first_name = @first_name
   and last_name = @last_name
   and super_user = @super_user
   and status = @status
   and last_modified_dte = @last_modified_dte
   and last_modified_by = @last_modified_by
   and roles = @roles