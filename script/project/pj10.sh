#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj10"
echo "parted gpt default nf raw"
/root/fiotest/script/expect/delete_default_partition.sh $2
/root/fiotest/script/expect/create_parted_gpt_default.sh $2
testPoint raw $1 $2
rm -rf temp1
move pj10
echo "pj10 done"
