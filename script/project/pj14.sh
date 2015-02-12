#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj14"
echo "parted gpt 4096 ext4 mount"
mkfs.ext4 -F /dev/$21
mount /dev/$21 /data1
testPoint mount $1 $2
rm -rf temp1
move pj14
umount /data1
echo "pj14 done"
