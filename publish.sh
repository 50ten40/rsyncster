#!/bin/bash
# push-datasync.sh - Publish staging to live on all development servers.

LIB_PATH="$HOME/manage/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

stagingservers=(localhost 192.168.0.206) # Multiple staging locations, (your workflow may vary) TODO: Get from .env.sh

if [ -d /tmp/.one-publish-rsync.$1.lock ]; then
   echo " - TASK : rsync lock exists : Continuing publish." >> $status
fi

if [ $1 ]; then
   ONEDOMAIN=$1
else
   echo -e "\n\tERROR: You must include a domain name on the command line when invoking this script.\n"
   exit
fi

mkdir -v /tmp/.one-publish-rsync.$1.lock

if [ $? == "1" ]; then
   echo "$(timestamp) - FAILURE : cannot create lock" >> $status
   exit 1
else
   echo "$(timestamp) - SUCCESS : created lock" >> $status
fi

for i in ${stagingservers[@]}; do
   echo "$(timestamp) - ===== Beginning publish of staging -> live on $i =====" >> $status
   if [ "$i" = "localhost" ]; then
      nice -n 20 /usr/bin/rsync -avilzx --delete-before --exclude-from=$LIB_PATH/exclusions.lst $DOCROOT_DIR/staging/$PREFIX.$ONEDOMAIN/ $DOCROOT_DIR/live/$PREFIX.$ONEDOMAIN/
      nginx_conf="/etc/nginx/sites-enabled/static.$ONEDOMAIN.conf"
      if [ ! -L "$nginx_conf" ]; then
         cd /etc/nginx/sites-enabled && sudo ln -s ../sites-available/static.$ONEDOMAIN.conf && systemctl reload nginx.service
      fi
   else
      nice -n 20 /usr/bin/rsync -avilzx --delete-before --exclude-from=$LIB_PATH/exclusions.lst -e ssh $DOCROOT_DIR/staging/$PREFIX.$ONEDOMAIN/ root@$i:$DOCROOT_DIR/live/$PREFIX.$ONEDOMAIN/
   fi

   if [ $? = "1" ]; then
      echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation " >> $status
      exit 1
   fi
      echo " - TASK : ===== Completed publish of staging -> live for $i =====" >> $status
done

rmdir -v /tmp/.one-publish-rsync.$1.lock
echo "$(timestamp) - SUCCESS : rsync publish completed successfully" >> $status
