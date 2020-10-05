#!/bin/bash
# Initialize appserver

LIB_PATH="$HOME/manage/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

if [ -d /tmp/.init-appserver.lock ]; then

	echo -e "FAILURE : rsync .init-webhead.lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon.\n" >> $status

	if [[ debug="yes" ]] ; then
		cat $status
	fi

	exit 1
fi

if [ $1 ]; then

        WEBHEAD_IP=$1
else
        
	echo -e "\n\tERROR: You must include the IP address of the new webhead on the command line when invoking this script.\n" >> $status
	
	if [[ debug="yes" ]] ; then
	        cat $status
	fi
	
	exit 1

fi

mkdir -v /tmp/.init-appserver.lock

if [ $? = "1" ]; then

	echo -e "$(timestamp) - FAILURE : cannot create .init.appserver.lock" >> $status
	
	if [[ debug="yes" ]] ; then
		cat $status
	fi

	exit 1

else
	
	echo "$(timestamp) - SUCCESS : created init.appserver.lock" >> $status

fi

echo "$(timestamp) - ===== Initializing new appserver with IP $1 =====" >> $status

if  ! ssh root@$WEBHEAD_IP "test -d $DOCROOTDIR"; then

	ssh root@$WEBHEAD_IP "mkdir $DOCROOTDIR"
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

      if [[ debug="yes" ]] ; then
	 cat $status
      fi

rsync -avilzx -e ssh $LOCAL_NGINX_PATH/sites-available/ root@$WEBHEAD_IP:$REMOTE_NGINX_PATH/sites-available/
rsync -avilzx -e ssh $LOCAL_NGINX_PATH/sites-enabled/ root@$WEBHEAD_IP:$REMOTE_NGINX_PATH/sites-enabled/
rsync -avilzx -e ssh $LOCAL_NGINX_PATH/snippets/ root@$WEBHEAD_IP:$REMOTE_NGINX_PATH/snippets/

ssh root@$WEBHEAD_IP "$REMOTE_NGINX_CMD"

if [ $? = "1" ]; then

	echo "$(timestamp) - FAILURE : init appserver failed. Please refer to the solution documentation " >> $status
	
	if [[ debug="yes" ]] ; then
		cat $status
	fi
	exit 1

fi

echo "$(timestamp) - ===== Completed init appserver on $WEBHEAD_IP =====" >> $status
rmdir -v /tmp/.init.appserver.lock
echo "$(timestamp) - SUCCESS : Removed init.appserver.lock" >> $status

if [[ debug="yes" ]] ; then
	cat $status
fi
