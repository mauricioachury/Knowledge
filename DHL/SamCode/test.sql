#use $DCSDIR/include
#include <dcsddl.h>
#include <dcscolwid.h>
#include <dcstbldef.h>
#use $MOCADIR/include
#include <sqlDataTypes.h>
#use $LESDIR/include
#include <varcolwid.h>

mset command on

[drop table abc]

RUN_DDL

mset command off
