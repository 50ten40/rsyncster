#!/bin/bash
# Initialize static webhead

LIB_PATH="$HOME/manage/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

#status="$MANAGE_DIR/datasync-init-webhead-$1.status"

if [ -d /tmp/.init-webhead.lock ]; then

	echo "FAILURE : rsync .init-webhead.lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." >> $status
	cat $status
	exit 1
fi

if [ $1 ]; then

        WEBHEAD_IP=$1
else
        
	echo -e "\n\tERROR: You must include the IP address of the new webhead on the command line when invoking this script.\n"
        cat $status
	exit 1

fi

mkdir -v /tmp/.init-webhead.lock

if [ $? = "1" ]; then

	echo "$(timestamp) - FAILURE : cannot create .init.webhead.lock" >> $status
	cat $status
	exit 1

else
	
	echo "$(timestamp) - SUCCESS : created lock" >> $status

fi

echo "$(timestamp) - ===== Initializing static webhead with IP $1 =====" >> $status

if  ! ssh root@$WEBHEAD_IP "test -d /var/www/html/live"; then

	ssh root@$WEBHEAD_IP "mkdir /var/www/html/live" # todo: update for env.sh variable
fi

if "[ -d "/etc/nginx" ]"; then
         echo " - NOTICE : Found local linux nginx config dir on $i" >> $status
         LOCAL_NGINX_PATH="/etc/nginx"
	 LOCAL_NGINX_CMD="systemctl condreload nginx"
      else
         echo " - NOTICE : Found local bsd nginx config dir on $i" >> $status
         LOCAL_NGINX_PATH="/usr/local/etc/nginx"
	 LOCAL_NGINX_CMD="service nginx reload"
      fi

if ssh root@$i "[ -d "/etc/nginx" ]"; then
         echo " - NOTICE : Found remote linux nginx config dir on $i" >> $status
         REMOTE_NGINX_PATH="/etc/nginx"
	 REMOTE_NGINX_CMD="systemctl condreload nginx"
      else
         echo " - NOTICE : Found remote bsd nginx config dir on $i" >> $status
         REMOTE_NGINX_PATH="/usr/local/etc/nginx"
	 REMOTE_NGINX_CMD="service nginx reload"
      fi

nice -n 20 /usr/bin/rsync -avilzx -e ssh $LOCAL_NGINX_PATH/sites-available/ root@$WEBHEAD_IP:$REMOTE_NGINX_PATH/sites-available/
nice -n 20 /usr/bin/rsync -avilzx -e ssh $LOCAL_NGINX_PATH/sites-enabled/ root@$WEBHEAD_IP:$REMOTE_NGINX_PATH/sites-enabled/
nice -n 20 /usr/bin/rsync -avilzx -e ssh $LOCAL_NGINX_PATH/snippets/ root@$WEBHEAD_IP:$REMOTE_NGINX_PATH/snippets/

ssh root@$WEBHEAD_IP "$REMOTE_NGINX_CMD"

if [ $? = "1" ]; then

	echo "$(timestamp) - FAILURE : init webhead failed. Please refer to the solution documentation " >> $status
	exit 1

fi

echo "$(timestamp) - ===== Completed initi webhead on $i =====" >> $status
rmdir -v /tmp/.initwebhead.lock
echo "$(timestamp) - SUCCESS : Init webhead completed successfully" >> $status
