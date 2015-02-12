#!/usr/bin/expect
set dev [lindex $argv 0]
spawn fdisk /dev/$dev

expect {
	"*WARNING*" { send "u\r" ;exp_continue }
	"*sectors" { send "n\r" ;exp_continue }
	"*primary*" { send "p\r" ;exp_continue }
	"Partition number*" { send "1\r" ;exp_continue }
	"First sector*" { send "8192\r" }

}
send "\r"
send "p\r"
send "w\r"
expect eof
