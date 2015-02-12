#!/bin/bash

set -e

for type in randwrite randread read write
do
    for pj in pj{1..15}
    do
        #fio
        cat /root/fiotest/data/$pj/$type'_4k_fio.txt' | grep iops | awk -F 'iops=' '{print $2}'|awk '{print $1}'>>4k_$type'.txt'
        cat /root/fiotest/data/$pj/$type'_512k_fio.txt' | grep iops | awk -F 'bw=' '{print $2}'|awk -F 'MB/s' '{print $1}'>>512k_$type'.txt'
        cat /root/fiotest/data/$pj/$type'_1024k_fio.txt' | grep iops | awk -F 'bw=' '{print $2}'|awk -F 'MB/s' '{print $1}'>>1024k_$type'.txt'
        #last30
        cat /root/fiotest/data/$pj/$type'_4k_last30_aver.txt' | grep last| awk -F '=' '{print $2}'>>4k_$type'_last30.txt'
        cat /root/fiotest/data/$pj/$type'_512k_last30_aver.txt' | grep last| awk -F '=' '{print $2}'>>512k_$type'_last30.txt'
        cat /root/fiotest/data/$pj/$type'_1024k_last30_aver.txt' | grep last| awk -F '=' '{print $2}'>>1024k_$type'_last30.txt'
    done

    mkdir $type
    mv *.txt $type/
done
