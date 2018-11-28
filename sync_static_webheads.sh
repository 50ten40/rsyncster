#!/bin/bash
# push-datasync.sh - Push one site's updates from master server to front end web servers via rsync

webservers=(192.237.251.89 lrsint) #todo: use /etc/hosts and generate prefixes; we do not syncting due to delay on publish. eg staging->live.
MANAGE_DIR="/home/kelley/manage"
timestamp() {
        date +"%Y-%m-%d %H:%M:%S"
}

status="$MANAGE_DIR/datasync-webheads-$1.status"

if [ -d /tmp/.webheads.lock ]; then
	echo "$(timestamp) - FAILURE : rsync publish-rsync.lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." > $status
	exit 1
fi

if [ $1 ]; then

        ONEDOMAIN=$1
else
        echo -e "\n\tERROR: You must include a domain name on the command line when invoking this script.\n"
        exit
fi

mkdir -v /tmp/.webheads.lock

if [ $? = "1" ]; then
	echo "$(timestamp) - FAILURE : cannot create .webheads.lock" >> $status
	exit 1
else
	echo "$(timestamp) - SUCCESS : created .webheads.lock" >> $status
fi

for i in ${webservers[@]}; do

	echo "$(timestamp) - ===== Beginning rsync of static docroot on $i ====="

	if ! [ $i = "192.237.251.89" ]; then
		PREFIX="static"
	else
		PREFIX="db2.static"
	fi

	nice -n 20 /usr/bin/rsync -avilzx --delete-before --exclude-from=$MANAGE_DIR/rsyncster/lib/rsync-exclusions.lst -e ssh /var/www/html/live/m.$ONEDOMAIN/ root@$i:/var/www/html/live/m.$ONEDOMAIN/
	nice -n 20 /usr/bin/rsync -avilzx -e ssh /etc/nginx/sites-available/$PREFIX.$ONEDOMAIN.conf root@$i:/etc/nginx/sites-available/


	if ! ssh root@$i "test -e /etc/nginx/sites-enabled/$PREFIX.$ONEDOMAIN.conf"; then
		ssh root@$i "cd /etc/nginx/sites-enabled && ln -s ../sites-available/$PREFIX.$ONEDOMAIN.conf" 
		ssh root@$i "systemctl condreload nginx"
		ssh root@$i "systemctl status nginx"
	fi

	if [ $? = "1" ]; then
		echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation " >> $status
		exit 1
	fi

	echo "$(timestamp) - ===== Completed rsync of static docroot on $i =====";
done

rmdir -v /tmp/.webheads.lock

echo "$(timestamp) - SUCCESS : rsync completed successfully" >> $status
