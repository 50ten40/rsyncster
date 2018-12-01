#!/bin/bash
# push-datasync.sh - Push one site's updates from master server to front end web servers via rsync

LIB_PATH="$HOME/manage/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

webservers=(localhost) # Multiple staging locations, (your workflow may vary)

#status="$MANAGE_DIR/datasync-$CHANGES_STRING.status"

if [ -d /tmp/.one-publish-rsync.lock ]; then
	echo "$(timestamp) - FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." >> $status
	exit 1
fi

if [ $1 ]; then

        ONEDOMAIN=$1
else
        echo -e "\n\tERROR: You must include a domain name on the command line when invoking this script.\n"
        exit
fi

mkdir -v /tmp/.one-publish-rsync.lock

if [ $? == "1" ]; then
	echo "$(timestamp) - FAILURE : cannot create lock" >> $status
	exit 1
else
	echo "$(timestamp) - SUCCESS : created lock" >> $status
fi


for i in ${webservers[@]}; do

	echo "$(timestamp) - ===== Beginning publish of staging -> live on $i =====" >> $status

	if [ "$i" = "localhost" ]; then

		nginx_conf="/etc/nginx/sites-enabled/static.$ONEDOMAIN.conf"
		
		if [ "$2" == "upgrade" ]; then

			echo " - TASK : Getting files for $1 from $APP_SERVERS_MASTER" >> $status

			nice -n 20 rsync -avilzx --delete-before --exclude-from=$LIB_DIR/exclusions.lst -e ssh $APP_SERVERS_MASTER:$DOCROOT_DIR/stockphoto.tools/sites/all/ $DOCROOT_DIR/staging/m.$ONEDOMAIN/sites/all/

			echo " - TASK : Syncing libraries for $1 on $i" >> $status
			nice -n 20 rsync -avilzx --delete-before -- $DOCROOT_DIR/stockphoto.tools/sites/all/libraries $DOCROOT_DIR/staging/m.$ONEDOMAIN/sites/all/libraries
			echo " - TASK : Syncing themes for $1 on $i" >> $status
			nice -n 20 rsync -avilzx --delete-before $DOCROOT_DIR/stockphoto.tools/sites/all/themes $DOCROOT_DIR/staging/m.$ONEDOMAIN/sites/all/themes
			echo " - TASK : Syncing modiules for $1 on $i" >> $status
			nice -n 20 rsync -avilzx --delete-before $DOCROOT_DIR/stockphoto.tools/sites/all/modules $DOCROOT_DIR/staging/m.$ONEDOMAIN/sites/all/modules
		fi
		
		nice -n 20 /usr/bin/rsync -avilzx --delete-before --exclude-from=$LIB_DIR/exclusions.lst $DOCROOT_DIR/staging/m.$ONEDOMAIN/ $DOCROOT_DIR/live/m.$ONEDOMAIN/
	
		if [ ! -f "$nginx_conf" ]; then
			cd /etc/nginx/sites-enabled && sudo ln -s ../sites-available/static.$ONEDOMAIN.conf && systemctl reload nginx.service
		fi
	else
		nice -n 20 /usr/bin/rsync -avilzx --delete-before --exclude-from=$LIB_DIR/exclusions.lst -e ssh $DOCROOT_DIR/staging/m.$ONEDOMAIN/ root@$i:$DOCROOT_DIR/live/m.$ONEDOMAIN/
	fi

	if [ $? = "1" ]; then
		echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation " >> $status
		exit 1
	fi

	echo " - TASK : ===== Completed publish of staging -> live for $i =====" >> $status
done

rmdir -v /tmp/.one-publish-rsync.lock

echo "$(timestamp) - SUCCESS : rsync publush completed successfully" >> $status
