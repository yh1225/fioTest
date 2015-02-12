#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj13"
echo "parted gpt 8192 nf raw"
/root/fiotest/script/expect/delete_default_partition.sh $2
/root/fiotest/script/expect/create_parted_gpt_4096.sh $2
testPoint raw $1 $2
rm -rf temp1
move pj13
echo "pj13 done"
