#!/bin/bash

kill_fio(){
while true
do
hostname = `hostname`
#echo "$hostname health is start "| mail -s "$hostname health is start " 421083173@qq.com 
/root/health_data/health_expect.sh > health.log
health_data=`cat health.log | grep "Warranty Remaining"| awk '{print $4}'`
if (( "$health_data" == 92 ))
then
	echo "ok"
	killall -9 fio
	killall -9 iostat
	break
else
	: 
fi 
done
} 

fiotest(){
	fio -filename=/dev/$1 -direct=1 -rw=randwrite -bs=4k -size=1T -numjobs=64  -group_reporting -name=$1_health & iostat -x $1 1 > $1_iostat.log
}

data_collect(){
cat $1_iostat.log | grep $1 | awk '{print $7}' > $1_tps.log
#echo "$hostname health is ok " |mail -s "$hostname health is ok " 421083173@qq.com 
}
