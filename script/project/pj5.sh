#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj5"
echo "sectors ext4 mount"
mkfs.ext4 -F /dev/$21
mount /dev/$21 /data1
testPoint mount $1 $2
rm -rf temp1
move pj5

umount /dev/$21
echo "pj5 done"
