#!/bin/bash
# Kyle Vandoremalen - March 2025
# General security checkup of users, connections and services/jobs

#clear screen before outputting results
export TERM=xterm
tput reset

# Text file with approved users
APPROVED_USERS="/home/kyle/scripts/allowed_users.txt"
mapfile -t approved_users < "$APPROVED_USERS"

# Compare to users in /etc/passwd to find any suspicious accounts
echo "#### ROUTINE SECURITY CHECK-IN ####"
echo ""
echo "Checking for suspicious users...			(Run 'userdel -r <username>' to delete unwanted users)"
echo ""


while IFS=: read -r username _ uid _; do
	if [[ $uid -ge 1000 ]]; then
		if ! grep -Fxq "$username" "$APPROVED_USERS"; then
			echo "Suspicious user found:  $username"
		fi
	fi
done < /etc/passwd

echo "------------------"

# Check for suspicious users logged in
echo "Users logged in:					(Run 'sudo pkill -KILL -u <username>' to terminate unwanted logins)"
echo ""
w -h | awk '{print $1}'


echo "------------------"

# Check for established connections and from which IP
echo "Established connections from other servers:	(Kill suspicious connections with 'kill -9 <pid>')"
echo ""
netstat -tuna -p | grep ESTABLISHED
echo "-------------------"

# Check for any .sh or .py services running
echo "Checking for any suspicious processes:		(Kill suspicious connections with -kill -9 <pid>')"
ps aux | grep -E '\.sh$|\.py$' | grep -v 'grep' | grep -v '/secure.sh'
ps aux | grep "nc " | grep -v 'grep'
echo "-------------------"

# Display existing user or system cronjobs
echo "Cronjobs in /etc/crontab"
tail -n +15 /etc/crontab
echo ""
echo "Cronjobs in /etc/crond.d/"
tail -n +5 /etc/cron.d/* 2>/dev/null
echo ""
echo "User cronjobs in /var/spool/cron"
cat /var/spool/cron/*
echo "-------------------"
echo "IP addresses found:				(Remove unwanted IPs with 'ip addr del <ip> dev <dev name>. Or Check network files)"
echo ""
ip a | grep inet
echo "-------------------"
echo "Running jobs:						(Kill any suspicious jobs with 'kill -9 %X')"
jobs
echo "-------------------"
echo "Looking for reverse shells...		(Kill any PIDS that might show an attackers IP, or netcat commands again)"
echo ""
pgrep -af "bash|nc |socat" | grep -v '/secure.sh'
echo ""
echo "#### Security check-in complete! ####"
echo ""
