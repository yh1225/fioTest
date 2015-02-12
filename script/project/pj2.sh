#!/bin/bash

source /root/fiotest/script/function.sh
echo "This is pj2"
echo "np nf raw"
mkfs.ext4 -F /dev/$2
mount /dev/$2 /data1
testPoint mount $1 $2
rm -rf temp1
move pj2
umount /dev/$2
echo "pj2 done"
