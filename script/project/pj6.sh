#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj6"
echo "sectors xfs mount"
mkfs.xfs -f /dev/$21
mount /dev/$21 /data1
testPoint mount $1 $2
rm -rf temp1
move pj6
umount /dev/$21
echo "pj6 done"
