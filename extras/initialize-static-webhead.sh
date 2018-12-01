#!/bin/bash
# Initialize static webhead

LIB_PATH="$HOME/manage/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

#status="$MANAGE_DIR/datasync-init-webhead-$1.status"

if [ -d /tmp/.init-webhead.lock ]; then

	echo "FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." >> $status
	exit 1
fi

if [ $1 ]; then

        WEBHEAD_IP=$1
else
        
	echo -e "\n\tERROR: You must include the IP address of the new webhead on the command line when invoking this script.\n"
        exit

fi

mkdir -v /tmp/.init-webhead.lock

if [ $? = "1" ]; then

	echo "$(timestamp) - FAILURE : cannot create lock" >> $status
	exit 1

else
	
	echo "$(timestamp) - SUCCESS : created lock" >> $status

fi

echo "$(timestamp) - ===== Initializing static webhead with IP $1 =====" >> $status

if  ! ssh root@$WEBHEAD_IP "test -e /var/www/html/live/"; then

	ssh root@$WEBHEAD_IP "cd /var/www/html/ && ln -s /home/kelley/static_sites live"

fi

nice -n 20 /usr/bin/rsync -avilzx -e ssh /etc/nginx/sites-available/ root@$WEBHEAD_IP:/etc/nginx/sites-available/
nice -n 20 /usr/bin/rsync -avilzx -e ssh /etc/nginx/sites-enabled/ root@$WEBHEAD_IP:/etc/nginx/sites-enabled/
nice -n 20 /usr/bin/rsync -avilzx -e ssh /etc/nginx/snippets/ root@$WEBHEAD_IP:/etc/nginx/snippets/

ssh root@$WEBHEAD_IP "systemctl condreload nginx"
ssh root@$WEBHEAD_IP "systemctl status nginx"

if [ $? = "1" ]; then

	echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation " >> $status
	exit 1

fi

echo "$(timestamp) - ===== Completed rsync of http docroot on $i =====" >> $status
rmdir -v /tmp/.initwebhead.lock
echo "$(timestamp) - SUCCESS : rsync completed successfully" >> $status
