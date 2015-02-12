#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj8"
echo "sectors 8192 ext4 mount"
mkfs.ext4 -F /dev/$21
mount /dev/$21 /data1
testPoint mount $1 $2
rm -rf temp1
move pj8
umount /data1
echo "pj8 done"
