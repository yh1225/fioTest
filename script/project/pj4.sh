#!/bin/bash

 /root/fiotest/script/expect/create_sectors_default.sh $2
 source /root/fiotest/script/function.sh

echo "This is pj4"
echo "sectors default raw"
testPoint raw $1 $2
rm -rf temp1
move pj4
echo "pj4 done"
