#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj3"
echo "np xfs mount"
mkfs.xfs -f /dev/$2
mount /dev/$2 /data1
testPoint mount $1 $2
rm -rf temp1
move pj3
umount /dev/$2
echo "pj3 done"
