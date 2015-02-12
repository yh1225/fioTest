#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj12"
echo "parted gpt default xfs mount"
mkfs.xfs -f /dev/$21
mount /dev/$21 /data1
testPoint mount $1 $2
rm -rf temp1
move pj12
umount /data1
echo "pj12 done"
