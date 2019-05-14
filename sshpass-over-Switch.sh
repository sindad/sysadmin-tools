#!/bin/bash
EMAIL="$1,$2,$3,$4,$5"
while read line
do
	export SSHPASS=$(echo $line | awk -F':' '{print $3}')
	user=$(echo $line | awk -F':' '{print $2}')
	ip=$(echo $line | awk -F':' '{print $1}')
        [ ! -d $ip ] && mkdir $ip
	echo "Backing up ($ip)"
	confpath="./${ip}/${ip}_$(date +"%Y-%m-%d_%H-%M-%S").txt"
	res=$(sshpass -e scp -o StrictHostKeyChecking=no -oKexAlgorithms=+diffie-hellman-group1-sha1 -c aes128-cbc   $user@$ip:running-config $confpath 2>&1)
	exit_code=$?
	echo "$?" "->" "$res"
	if [ $? -eq $exit_code ] ; then 
		echo "Done"
		echo "backup for switch $ip" |sudo mutt -a "$confpath" -s "a backup for Configurations of switch $ip at sindad Data Center " -- $EMAIL
	else
		echo "In $(date +'%Y-%m-%d_%H-%M-%S') we tried to get a backup from $ip and it failed with following log. Please check the log and try to solve the problem.\n\n###\n$res\n###" | sudo mutt -s "backup for switch $ip" -- $EMAIL
	       	echo "Failed"
	fi
done <&0
