#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj11"
echo "parted gpt default ext4 mount"
mkfs.ext4 -F /dev/$21
mount /dev/$21 /data1
testPoint mount $1 $2
rm -rf temp1
move pj11
umount /data1
echo "pj11 done"
