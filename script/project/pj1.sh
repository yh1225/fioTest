#!/bin/bash
#$1->time $2->sdk
source /root/fiotest/script/function.sh
echo "This is pj1"
echo "np nf raw"
testPoint raw $1 $2
rm -rf temp1
move pj1
echo "pj1 done"
