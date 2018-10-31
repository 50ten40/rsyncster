#!/bin/bash
# Initialize static webhead
# Syncthing syncs document root, this script symlinks to live folder.

SYNC_DIR="/home/kelley/kg\ -\ Drupal\ Multisite/static_sites"
LIVE_DIR=live
DOCROOT=/var/www/html
NGINX_ROOT=/etc/nginx
NGINX_AVAIL=$NGINX_ROOT/sites-available
NGINX_ENABL=$NGINX_ROOT/sites-enabled

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

if  ! ssh root@$WEBHEAD_IP "test -e $DOCROOT/$LIVE_DIR"; then
	root@$WEBHEAD_IP cd $DOCROOT && ln -sv $SYNC_DIR $LIVE_DIR
fi

nice -n 20 /usr/bin/rsync -avilzx -e ssh $NGINX_AVAIL/ root@$1:$NGINX_AVAIL/
nice -n 20 /usr/bin/rsync -avilzx -e ssh $NGINX_ENABL/ root@$1:$NGINX_ENABL/
 
ssh root@$i "systemctl condreload nginx"
ssh root@$i "systemctl status nginx"

if [ $? = "1" ]; then
	echo "FAILURE : rsync failed. Please refer to the solution documentation " > $status
	exit 1
fi

echo "===== Completed rsync of http docroot on $i =====";
rmdir -v /tmp/.one-webhead-rsync.lock
echo "SUCCESS : rsync completed successfully" > $status
