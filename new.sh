#!/bin/bash
	source script/function.sh
set -e

#fio -filename=/dev/sde -direct=1 -rw=randwrite -bs=4k -numjobs=64 -runtime=1800 -group_reporting -name=test

#	for p in pj{2..15}
#	do
#		./script/project/$p.sh 1800 $1
#done
sendmail
