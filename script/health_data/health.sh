#!/bin/bash


source health_function.sh

	#mkfs.xfs -f /dev/$1
	#mount /dev/$1 /data1
curl -d "username=test.team.no&password=duduadmin@15q2&login_type=login&uri=aHR0cDovLzE5Mi4xNjguNjAuNjUv" http://10.3.1.193/
kill_fio &fiotest $1
data_collect $1

