#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj15"
echo "parted gpt 4096 xfs mount"
mkfs.xfs -f /dev/$21
mount /dev/$21 /data1
testPoint mount $1 $2
rm -rf temp1
move pj15
umount /data1
echo "pj15 done"
