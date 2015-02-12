#!/bin/bash
#$1->sdname $2->write/read/rw/rr $3->4k/512k/1024k $4->runtime
fio_test_raw(){
fio -filename=/dev/$1 -direct=1 -rw=$2 -bs=$3 -size=400G -numjobs=64 -runtime=$4 -group_reporting -name=$2_$3_64 >$2_$3_fio.txt
}

fio_test_mount(){
 delete_fio_file
 df
 fio -filename=/data1/test1:/data1/test2:/data1/test3:/data1/test4:/data1/test5:/data1/test6:/data1/test7:/data1/test8:/data1/test9:/data1/test10 -direct=1 -rw=$2 -bs=$3 -size=400G -numjobs=64 -runtime=$4 -group_reporting -name=$2_$3_64 >$2_$3_fio.txt
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
	mail_date
	/etc/init.d/sendmail restart
	mail -s "$servername SSD test is ok" 421083173@qq.com < fiotest.log 
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

