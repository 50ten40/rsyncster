#!/bin/bash
# push-datasync.sh - Push one site's updates from master server to front end web servers via rsync

webservers=(192.237.251.89 lrsint) #todo: use /etc/hosts and generate prefixes; we do not syncting due to delay on publish. eg staging->live.
status="/tmp/datasync-rack-$1.status"

if [ -d /tmp/.one-rack-rsync.lock ]; then
	echo "FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." > $status
	exit 1
fi

if [ $1 ]; then

        ONEDOMAIN=$1
else
        echo -e "\n\tERROR: You must include a domain name on the command line when invoking this script.\n"
        exit
fi

mkdir -v /tmp/.one-rack-rsync.lock

if [ $? = "1" ]; then
	echo "FAILURE : cannot create lock" > $status
	exit 1
else
	echo "SUCCESS : created lock" > $status
fi

for i in ${webservers[@]}; do

	echo "===== Beginning rsync of static docroot on $i ====="

	if ! [ $i = "192.237.251.89" ]; then
		PREFIX="static"
	else
		PREFIX="db2.static"
	fi

	nice -n 20 /usr/bin/rsync -avilzx --delete-before --exclude-from=./lib/rsync-exclusions.lst -e ssh /var/www/html/live/m.$ONEDOMAIN/ root@$i:/var/www/html/live/m.$ONEDOMAIN/
	nice -n 20 /usr/bin/rsync -avilzx -e ssh /etc/nginx/sites-available/$PREFIX.$ONEDOMAIN.conf root@$i:/etc/nginx/sites-available/


	if ! ssh root@$i "test -e /etc/nginx/sites-enabled/$PREFIX.$ONEDOMAIN.conf"; then
		ssh root@$i "cd /etc/nginx/sites-enabled && ln -s ../sites-available/$PREFIX.$ONEDOMAIN.conf" 
		ssh root@$i "systemctl condreload nginx"
		ssh root@$i "systemctl status nginx"
	fi

	if [ $? = "1" ]; then
		echo "FAILURE : rsync failed. Please refer to the solution documentation " > $status
		exit 1
	fi

	echo "===== Completed rsync of static docroot on $i =====";
done

rmdir -v /tmp/.one-rack-rsync.lock

echo "SUCCESS : rsync completed successfully" > $status
