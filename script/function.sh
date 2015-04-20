#!/bin/bash
init(){
	/root/fiotest/script/expect/create_parted_gpt_4096.sh $1
	size=`fdisk -l | grep $1 | awk '{print $3}'| awk -F '.' '{print $1}'`
	echo $size
	let ssize=$size * 5 
	echo $ssize
	fio_test_raw $1 write 512k 0 2400 
	fio_test_raw $1 write 512k 0 $size
	fio -filename=/dev/$1 -direct=1 -rw=write -bs=512k -size=2400G   -group_reporting -name=512k_write_64 
	fio_test_raw $1 write 4k 0 2400 
	fio -filename=/dev/$1 -direct=1 -rw=write -bs=4k -size=2400G   -group_reporting -name=4k_write_64 
	fio_test_raw $1 write 4k 0 $size
	fio_test_raw $1 randwrite 4k 0 2400
	fio -filename=/dev/$1 -direct=1 -rw=randwrite -bs=4k -size=2400G   -group_reporting -name=4k_randwrite_64 
	fio_test_raw $1 randwrite 4k 0 $size

	sendmail "initdone"

}
#$1->sdname
stability_test(){
	fio_test_raw $1 write 4k $2
	iostat_test $1 stability_4k_raw.txt&fio_test_raw $1 write 4k $2
	killall -9 iostat
    	grep $1 stability_4k_raw.txt > temp
	awk '{print $10}' temp > stability_4k_raw_await.txt
	awk '{print $5}' temp > stability_4k_raw_iops.txt
	rm -rf temp
	mv write_4k_fio.txt stability_raw_fio.txt
	
	mkfs.xfs -f /dev/$11
	mount /dev/$11 /data1
	iostat_test $1 stability_4k_xfs.txt&fio_test_mount $1 write 4k $2
	killall -9 iostat
    	grep $1 stability_4k_xfs.txt > temp
	awk '{print $10}' temp > stability_4k_xfs_await.txt
	awk '{print $5}' temp > stability_4k_xfs_iops.txt
	rm -rf temp
	mv write_4k_fio.txt stability_xfs_fio.txt

if [ -d /root/fiotest/data/stability_test ]
	then
		:
	else
	mkdir /root/fiotest/data/stability_test
fi
	
	mv stability* /root/fiotest/data/stability_test
	if (  df | grep /data1 )
	then
	umount /data1
	else
		:
	fi
	
	sendmail "stability_test done"

}
#$1->sdname $2->raw/mount $3->4k/512k $4->iops/tps
performance_date_collect(){
	if (( "$number" < 17 ))
	then
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
				tail -n 500 performance_$3'_'$2'_'$ctype'_'$4'.txt'|awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1}END{printf"%f\n",sum/num}' >> Data_performance_$2'.log'
			
				else
					if [ "$ctype" = "randwrite" ]
					then
						awk '{print $7}' temp > performance_$3'_'$2'_'$ctype'_'$4'.txt'
					else
						awk '{print $6}' temp > performance_$3'_'$2'_'$ctype'_'$4'.txt'
					fi
					tail -n 500 performance_$3'_'$2'_'$ctype'_'$4'.txt'|awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1}END{printf"%f\n",sum/num}' >> Data_performance_$2'.log'
				fi
			rm -rf temp
			echo "performance_$3'_'$2'_'$ctype'_'$4'.txt'"
		done
	else
		for stype in write read
		do
			grep $1 performance_$3'_'$2'_'$stype'.txt' > temp
				if [ $4="iops" ]
				then
					if [ "$ctype" = "write" ]
					then
						awk '{print $5}' temp > performance_$3'_'$2'_'$stype'_'$4'.txt'
				else
					awk '{print $4}' temp > performance_$3'_'$2'_'$stype'_'$4'.txt'
					fi
				tail -n 500 performance_$3'_'$2'_'$stype'_'$4'.txt'|awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1}END{printf"%f\n",sum/num}' >> Data_performance_$2'.log'
			
				else
					if [ "$stype" = "write" ]
					then
						awk '{print $7}' temp > performance_$3'_'$2'_'$stype'_'$4'.txt'
					else
						awk '{print $6}' temp > performance_$3'_'$2'_'$stype'_'$4'.txt'
					fi
					tail -n 500 performance_$3'_'$2'_'$stype'_'$4'.txt'|awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1}END{printf"%f\n",sum/num}' >> Data_performance_$2'.log'
				fi
			rm -rf temp
			echo "performance_$3'_'$2'_'$stype'_'$4'.txt'"
		done
	
	fi	
}
		
	

#$1->sdname $2->runtime
performance_test(){
	echo "do"
	i=raw
		#	mkfs.xfs -f /dev/$1p1
	for type in  raw xfs
	do
#ÂàõÂª∫Êñá‰ª∂Â§π
		if [ -d /root/fiotest/data/performance_$type ]
			then
				:
			else
				mkdir /root/fiotest/data/performance_$type
		fi
#ÂºÄÂßãÊµãËØï
		for number in  4 8 16 128 512 1024
		do
			echo "$number"
			echo "$type"
#Êï∞ÊçÆÊî∂ÈõÜ
			if (( "$number" < 17 ))
			then
				echo "iops"
				performance_fio $1 $type $number'k' $2 
				performance_date_collect $1 $type $number'k'  iops
				mv performance* /root/fiotest/data/performance_$type
				mv rand* /root/fiotest/data/performance_$type

			else
				echo "tps"
				performance_fio_write $1 $type $number'k' $2  
				performance_date_collect $1 $type $number'k'  tps
				mv performance* /root/fiotest/data/performance_$type
				mv write* /root/fiotest/data/performance_$type
				mv read* /root/fiotest/data/performance_$type
				
			fi
		done		
#Êï∞ÊçÆÂΩíÁ±
		if [ "$i" = "raw" ]
		then
			mkfs.xfs -f /dev/$11
		else
			umount /data1
		fi
		i=mount	
		
	done
	echo done
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
		mount /dev/$11 /data1
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

performance_fio_write(){
if [ "$2" = "raw" ]
then
	echo raw_fio
	iostat_test $1 performance_$3'_raw_write'.txt&fio_test_raw $1 write $3 $4
	killall -9 iostat
	sleep 1
	iostat_test $1 performance_$3'_raw_read'.txt&fio_test_raw $1 read $3 $4
	killall -9 iostat
	sleep 1
else
	if (  df | grep /data1 )
	then 
		:
	else
		mount /dev/$11 /data1
	fi	
	echo xfs_fio
	iostat_test $1 performance_$3'_xfs_write'.txt&fio_test_mount $1 write $3 $4
	killall -9 iostat
	sleep 1
	iostat_test $1 performance_$3'_xfs_read'.txt&fio_test_mount $1 read $3 $4
	killall -9 iostat
	sleep 1
fi
}

#$1->sdname $2->write/read/rw/rr $3->4k/512k/1024k $4->runtime $5->size
fio_test_raw(){
if [ $4 = 0 ]
	#size performance
then
	fio -filename=/dev/$11 -direct=1 -rw=$2 -bs=$3 -size=$5G -numjobs=64  -group_reporting -name=$2_$3_64 
else
	#time tability
echo "fio_raw"
	fio -filename=/dev/$11 -direct=1 -rw=$2 -bs=$3  -numjobs=64 -runtime=$4 -group_reporting -name=$2_$3_64>$2_$3_fio.txt 
fi

}

fio_test_mount(){
 #delete_fio_file
	size=`fdisk -l | grep $1 | awk '{print $3}'| awk -F '.' '{print $1}'`

	echo $size
	 fio -filename=/data1/test1:/data1/test2:/data1/test3:/data1/test4:/data1/test5:/data1/test6:/data1/test7:/data1/test8:/data1/test9:/data1/test10 -direct=1 -rw=$2 -bs=$3 -numjobs=64 -runtime=$4 -size=400G  -group_reporting -name=$2_$3_64 >$2_$3_fio.txt

}

#$1->sdname $2->filename
iostat_test(){

        iostat -x 1 $1 >$2
}

sendmail(){
    severname=`hostname`
	if [ "$1" = "performance" ]
	then
         mail_date
         /etc/init.d/sendmail restart
         mail -s "$severname SSD $1 test is ok " 421083173@qq.com  < Data_$1'.log'
	else
        /etc/init.d/sendmail restart
        echo "$severname $1" | mail -s "$severname $1" 421083173@qq.com
	fi
}

mail_date(){
	touch Data_performance.log
	for mtype in raw xfs
	do
			echo "====="  $mtype performance test result"=====">> Data_performance.log
			cat Data_performance_$mtype'.log' >> Data_performance.log

	done
}


collect_data(){
for type1 in raw xfs
do
        for type2 in randwrite randread write read
        do
        if [ $type2 = "randwrite" -o $type2 = "randread" ]
        then
                for snumber in 4 8 16
                do
                cat /root/fiotest/data/performance_$type1/$type2'_'$snumber'k_fio.txt'| grep iops | awk -F 'iops=' '{print $2}'|awk '{print $1}'>>$1_iops'.txt'
                done
        else
                for mnumber in 128 512 1024
                do
                cat /root/fiotest/data/performance_$type1/$type2'_'$mnumber'k_fio.txt'| grep iops| awk -F 'bw=' '{print $2}'|awk -F 'MB/s' '{print $1}'>>$1_tps.txt
                done
        fi
        done
done
mv $1* /root/fiotest/data/

}

