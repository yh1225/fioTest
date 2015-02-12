#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj7"
echo "sectors 8192 nf raw"
/root/fiotest/script/expect/delete_default_partition.sh $2
/root/fiotest/script/expect/create_sectors_8192.sh $2
testPoint raw $1 $2
rm -rf temp1
move pj7
echo "pj7 done"
