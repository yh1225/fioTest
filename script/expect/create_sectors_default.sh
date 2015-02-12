#!/usr/bin/expect
set dev [lindex $argv 0]
spawn fdisk /dev/$dev

expect {
	"*DOS-compatible*" { send "u\r" ;exp_continue }
	"*sectors" { send "n\r" ;exp_continue }
	"*primary*" { send "p\r" ;exp_continue }
	"Partition number*" { send "1\r" ;exp_continue }
	"First sector*" { send "\n" }

}
send "\r"
send "w\r"
expect eof
