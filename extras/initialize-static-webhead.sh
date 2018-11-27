#!/bin/bash
# Initialize static webhead

status="/tmp/datasync-webhead-$1.status"

if [ -d /tmp/.one-webhead-rsync.lock ]; then
echo "FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." > $status
exit 1
fi

if [ $1 ]; then

        WEBHEAD_IP=$1
else
        echo -e "\n\tERROR: You must include the IP address of the new webhead on the command line when invoking this script.\n"
        exit
fi

mkdir -v /tmp/.one-webhead-rsync.lock

if [ $? = "1" ]; then
	echo "FAILURE : cannot create lock" > $status
	exit 1
else
	echo "SUCCESS : created lock" > $status
fi

echo "===== Initializing static webhead with IP $1 ====="

if  ! ssh root@$WEBHEAD_IP "test -e /var/www/html/live/"; then
	ssh root@$WEBHEAD_IP "cd /var/www/html/ && ln -s /home/kelley/static_sites live"
fi

nice -n 20 /usr/bin/rsync -avilzx -e ssh /etc/nginx/sites-available/ root@$WEBHEAD_IP:/etc/nginx/sites-available/
nice -n 20 /usr/bin/rsync -avilzx -e ssh /etc/nginx/sites-enabled/ root@$WEBHEAD_IP:/etc/nginx/sites-enabled/
nice -n 20 /usr/bin/rsync -avilzx -e ssh /etc/nginx/snippets/ root@$WEBHEAD_IP:/etc/nginx/snippets/

ssh root@$WEBHEAD_IP "systemctl condreload nginx"
ssh root@$WEBHEAD_IP "systemctl status nginx"

if [ $? = "1" ]; then
	echo "FAILURE : rsync failed. Please refer to the solution documentation " > $status
	exit 1
fi

echo "===== Completed rsync of http docroot on $i =====";
rmdir -v /tmp/.one-webhead-rsync.lock
echo "SUCCESS : rsync completed successfully" > $status
