#!/usr/bin/expect
set dev [lindex $argv 0]
spawn fdisk /dev/$dev
send "d\r"
send "w\r"
expect eof
