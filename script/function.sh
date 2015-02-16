#!/bin/bash
init(){
	/root/fiotest/script/expect/create_parted_gpt_4096.sh
	size=`fdisk -l | grep $1 | awk '{print $3}'| awk -F '.' '{print $1}'`
	((size=$size*5))
	fio_test_raw $1 write 512k 0 $size
	fio_test_raw $1 write 4k 0 $size
	fio_test_raw $1 randwrite 4k 0 $size

	sendmail "initdone"

}
#$1->sdname
stability_test(){
	iostat_test $1 stability_4k_raw.txt&fio_test_raw $1 write 4k $2
	killall -9 iostat
    grep $1 stability_4k_raw.txt > temp
	awk '{print $10}' temp > stability_4k_raw_await.txt
	awk '{print $5}' temp > stability_4k_raw_iops.txt
	rm -rf temp
	
	mkfs.xfs -f /dev/$1
	mount /dev/$1 /data1
	iostat_test $1 stability_4k_xfs.txt&fio_test_mount $1 write 4k 20
	killall -9 iostat
    grep $1 stability_4k_xfs.txt > temp
	awk '{print $10}' temp > stability_4k_xfs_await.txt
	awk '{print $5}' temp > stability_4k_xfs_iops.txt
	rm -rf temp
if [ -d /root/fiotest/data/stability_test ]
	then
		:
	else
	mkdir /root/fiotest/data/stability_test
fi
	mv stability* /root/fiotest/data/stability_test
	umount /data1
	 #sendmail "stability_test done"

}
#$1->sdname $2->raw/mount $3->4k/512k $4->iops/tps
performance_date_collect(){
	for ctype in randwrite randread
	do
		grep $1 performance_$3'_'$2'_'$ctype'.txt' > temp
		if [ $4="iops" ]
		then
			if [ "$ctype" = "randwrite" ]
			then
				awk '{print $5}' temp > performance_$3'_'$2'_'$ctype'_'$4'.txt'
			else
				awk '{print $4}' temp > performance_$3'_'$2'_'$ctype'_'$4'.txt'
			fi
			
		else
			if [ "$ctype" = "randwrite" ]
			then
				awk '{print $7}' temp > performance_$3'_'$2'_'$ctype'_'$4'.txt'
			else
				awk '{print $6}' temp > performance_$3'_'$2'_'$ctype'_'$4'.txt'
			fi
		fi
		rm -rf temp
	done
	
	
}

#$1->sdname $2->runtime
performance_test(){
	echo "do"
	i=raw
	for type in raw xfs
	do
		if [ -d /root/fiotest/data/performance_$type ]
			then
				:
			else
				mkdir /root/fiotest/data/performance_$type
		fi
		for number in 4 8 16 128 512 1024
		do
			echo "$number"
			echo "$type"
			performance_fio $1 $type $number'k' $2 
			if (( "$number" < 17 ))
			then
				echo "iops"
				performance_date_collect $1 $type $number'k'  iops
			else
				echo "tps"
				performance_date_collect $1 $type $number'k'  tps
			fi
		done		
		if [ "$i" = "raw" ]
		then
		mv performance* /root/fiotest/data/performance_$type
		mv rand* /root/fiotest/data/performance_$type
		mkfs.xfs -f /dev/$1
		else 
		mv performance* /root/fiotest/data/performance_$type
		mv rand* /root/fiotest/data/performance_$type
		umount /data1	
		fi
		
		i=mount
		#mv performance* /root/fiotest/data/performance_$1
	done
}
#$1->sdname $2->raw/mount  $3->4k/512k $4->runtime
performance_fio(){
if [ "$2" = "raw" ]
then
	echo raw_fio
	iostat_test $1 performance_$3'_raw_randwrite'.txt&fio_test_raw $1 randwrite $3 $4
	killall -9 iostat
	sleep 1
	iostat_test $1 performance_$3'_raw_randread'.txt&fio_test_raw $1 randread $3 $4
	killall -9 iostat
	sleep 1
else
	if (  df | grep /data1 )
	then 
		:
	else
		mount /dev/$1 /data1
	fi	
	echo xfs_fio
	iostat_test $1 performance_$3'_xfs_randwrite'.txt&fio_test_mount $1 randwrite $3 $4
	killall -9 iostat
	sleep 1
	iostat_test $1 performance_$3'_xfs_randread'.txt&fio_test_mount $1 randread $3 $4
	killall -9 iostat
	sleep 1
fi
}


#$1->sdname $2->write/read/rw/rr $3->4k/512k/1024k $4->runtime $5->size
fio_test_raw(){
#if [ $4 = 0 ]
	#size performance
#then
#	fio -filename=/dev/$1 -direct=1 -rw=$2 -bs=$3 -size=$5G -numjobs=64  -group_reporting -name=$2_$3_64 
#else
	#time tability
echo "fio_raw"
	fio -filename=/dev/$1 -direct=1 -rw=$2 -bs=$3  -numjobs=64 -runtime=$4 -group_reporting -name=$2_$3_64>$2_$3_fio.txt 
#fi

}

fio_test_mount(){
 #delete_fio_file
	size=`fdisk -l | grep $1 | awk '{print $3}'| awk -F '.' '{print $1}'`

	echo $size
	 fio -filename=/data1/test1:/data1/test2:/data1/test3:/data1/test4:/data1/test5:/data1/test6:/data1/test7:/data1/test8:/data1/test9:/data1/test10 -direct=1 -rw=$2 -bs=$3 -numjobs=64 -runtime=$4 -size=400G  -group_reporting -name=$2_$3_64 >$2_$3_fio.txt

}

#$1->write/read $2->iops/thorupt $3->filename $4->ssd
aver(){
grep $4 $3 > temp1
rm -rf $3
cp temp1 $3_all.txt
if [ "$1" == "write" ]
then
	if [ "$2" == "iops" ]
	then
        	awk '{print $5}' temp1 > temp2
	        tail -n 30 temp2 > temp3
       	        cat temp3 | awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1}END{printf"last 30 aver=%f\n",sum/num}' >> temp3
        	mv temp3 $3_last30_aver.txt
	else
        	awk '{print $7}' temp1 >temp2
	        tail -n 30 temp2 > temp3
       	        cat temp3 | awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1}END{printf"last 30 aver=%f\n",sum/num}' >> temp3
        	mv temp3 $3_last30_aver.txt
	fi
		
else
	if [ "$2" == "iops" ]
	then
        	awk '{print $4}'temp1 >temp2
	        tail -n 30 temp2 > temp3
       	        cat temp3 | awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1}END{printf"last 30 aver=%f\n",sum/num}' >> temp3
        	mv temp3 $3_last30_aver.txt
	else
        	awk '{print $6}'temp1 >temp2
	        tail -n 30 temp2 > temp3
       	        cat temp3 | awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1}END{printf"last 30 aver=%f\n",sum/num}' >> temp3
        	mv temp3 $3_last30_aver.txt
	fi
fi
rm -rf temp2

}
#$1->sdname $2->filename
iostat_test(){

        iostat -x 1 $1 >$2
}

#$1->raw/mount $2->runtime $3->sdname
testPoint(){
echo "======first test point randwrite running======"
source /root/fiotest/script/testPoint/testSSD1.sh $1 $2 $3
echo "======first test point done======"
echo "======second test point randread running======"
#source /root/fiotest/script/testPoint/testSSD2.sh $1 $2 $3
echo "======second test point done======"
echo "======third test point write running======"
#source /root/fiotest/script/testPoint/testSSD3.sh $1 $2 $3
echo "======third point done======"
echo "======last test point read running======"
#source /root/fiotest/script/testPoint/testSSD4.sh $1 $2 $3
echo "======last test point done======"
}

#$1->pj[1-15]
move(){

if [ -d /root/fiotest/data/$1 ]
   then
   	echo "file is exist"
   else 
	mkdir /root/fiotest/data/$1
fi

	mv rand* /root/fiotest/data/$1
	#mv write* /root/fiotest/data/$1
	#mv read* /root/fiotest/data/$1
}

delete_fio_file(){
if ( df | grep /data1 )  
   then 
	rm -rf /data1/test*
   else 
	echo " not mount /data1 "
fi
}


sendmail(){
    severname=`hostname`
	if [ -d $2 ]
	then
         mail_date
         /etc/init.d/sendmail restart
         mail -s "$severname SSD test is ok " 421083173@qq.com  < fiotest.log
	else
        /etc/init.d/sendmail restart
        echo "$severname $1" | mail -s "$severname $1" 421083173@qq.com
	fi
}

mail_date(){
	touch fiotest.log
	for type in randwrite randread read write
	do
		for bs in 4k 512k 1024k
		do
			echo "====="  $type $bs fio_result"=====">>fiotest.log
			cat $type/$bs'_'$type'.txt' >> fiotest.log
			echo "====="  $type $bs fio_last30"=====">>fiotest.log
			cat $type/$bs'_'$type'_last30.txt' >> fiotest.log

		done
	done
}


collect_date(){
	source /root/fiotest/data/collect_data.sh
}

