#!/bin/bash
#$1->raw/mount $2->runtime $3->sdname
#iostat_test $1->sdname $2->filename
#fio_test $1->sdname $2->r/w/rw/rr $3->4k/512k/1024k/ $4->runtime
#aver $1->write/read $2->iops/thruput $3->filename $4->sdname
echo "1 4k"
iostat_test $3 write_4k&fio_test_$1 $3 write 4k $2
killall -9 iostat
aver write iops write_4k $3
cat write_4k_last30_aver.txt
echo 1 done
echo "2 512k"
iostat_test $3 write_512k&fio_test_$1 $3 write 512k $2
killall -9 iostat
aver write thruput write_512k.txt $3
cat write_512k_last30_aver.txt
echo 2 done
echo "3 1024k"
iostat_test $3 write_1024k&fio_test_$1 $3 write 1024k $2
killall -9 iostat
aver write thruput write_1024k $3
cat write_1024k_last30_aver.txt
echo 3 done
