#!/bin/bash
	source script/function.sh
set -e

init $1
stability_test $1 90000
performance_test $1 1800
collect_data $1
sendmail

