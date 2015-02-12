#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj9"
echo "sectors 8192 xfs mount"
mkfs.xfs -f /dev/$21
mount /dev/$21 /data1
testPoint mount $1 $2
rm -rf temp1
move pj9
umount /data1
echo "pj9 done"
