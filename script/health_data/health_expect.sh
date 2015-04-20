#!/usr/bin/expect
set dev [lindex $argv 0]
spawn /root/ddcli 

#expect {
#	"Welcome*" { send "mklabel\r" ;exp_continue }
#	"New disk label type*" { send "gpt\r" ;exp_continue }
#	"*Yes*" { send "Yes\r"  }

#}
send "1\r"
send "3\r"
send "Yes\r"
send "Yes\r"
#expect {
#	"Start*" { send "4096\r" ;exp_continue }
#	"End*" { send "'-1'\r" }
#}
#send "q\r"

expect eof
