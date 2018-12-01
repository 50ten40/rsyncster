#!/bin/bash
# push-datasync.sh - Push one site's updates from master server to front end web servers via rsync

LIB_PATH="$HOME/manage/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

webservers=(192.237.251.89 lrsint) #todo: use /etc/hosts and generate prefixes; we do not syncting due to delay on publish. eg staging->live.

#status="$MANAGE_DIR/datasync-webheads-$1.status"

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

mkdir /tmp/.webheads.lock

if [ $? = "1" ]; then

	echo "$(timestamp) - FAILURE : cannot create .webheads.lock" >> $status
	exit 1

else

	echo " - SUCCESS : created .webheads.lock" >> $status

fi

for i in ${webservers[@]}; do

	echo " - TASK : ===== Beginning rsync push of  static content to $i =====" >> $status

	if ! [ $i = "192.237.251.89" ]; then
		PREFIX="static"
	else
		PREFIX="db2.static"
	fi

	nice -n 20 rsync -avilzx --delete-before --exclude-from=$LIB_DIR/exclusions.lst -e ssh $DOCROOT_DIR/live/m.$ONEDOMAIN/ root@$i:$DOCROOT_DIR/live/m.$ONEDOMAIN/
	nice -n 20 rsync -avilzx -e ssh /etc/nginx/sites-available/$PREFIX.$ONEDOMAIN.conf root@$i:/etc/nginx/sites-available/


	if ! ssh root@$i "test -e /etc/nginx/sites-enabled/$PREFIX.$ONEDOMAIN.conf"; then

		echo " - TASK : Configuring nginx for $i" >> $status
	 
		ssh root@$i "cd /etc/nginx/sites-enabled && ln -s ../sites-available/$PREFIX.$ONEDOMAIN.conf" 
		ssh root@$i "systemctl condreload nginx"
		ssh root@$i "systemctl status nginx"
	fi

	if [ $? = "1" ]; then
		echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation " >> $status
		exit 1
	fi

	echo " - TASK : ===== Completed rsync push of static content to $i =====" >> $status
done

rmdir /tmp/.webheads.lock

echo "$(timestamp) - SUCCESS : removed .webheads.lock successfully" >> $status
