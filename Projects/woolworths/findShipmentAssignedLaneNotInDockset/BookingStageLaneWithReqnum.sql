publish data where reqnum = 538907 and devcod = '139' and usr_id = '9849'
|
[update wrkque    set wrksts    = 'WAIT',        ackdevcod = @devcod,      ack_usr_id = @usr_id  where reqnum = @reqnum]
|
process var lane assignment where reqnum = @reqnum and wh_id = 'PRDC'
|
set return status where status = 123