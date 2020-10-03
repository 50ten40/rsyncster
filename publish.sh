#!/bin/bash
# push-datasync.sh - Publish staging to live on all development servers.

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_timestamp.sh

if [ -d /tmp/.one-publish-rsync.$1.lock ]; then
   echo " - TASK : rsync lock exists : Continuing publish." >> $status
else
   mkdir -v /tmp/.one-publish-rsync.$1.lock
fi

if [ $1 ]; then
   ONEDOMAIN=$1
else
   echo -e "\n\tERROR: You must include a domain name on the command line when invoking this script.\n"
   exit
fi

# Check that domain exists
if ! [ $(printf ${drupalfiles_list[@]} | grep -o "$ONEDOMAIN" | wc -w) ] ; then

   echo " - FAILURE - Domain must exist" >> $status
   cat $status | grep FAILURE
   exit 1

fi

if [ $? == "1" ]; then
   echo "$(timestamp) - FAILURE : cannot create lock" >> $status
   exit 1
else
   echo "$(timestamp) - SUCCESS : created lock" >> $status
fi

for i in ${stagingservers[@]}; do
   echo "$(timestamp) - ===== Beginning publish of staging -> live on $i =====" >> $status
   if [ "$i" = "localhost" ]; then
      nice -n 20 rsync -avilzx --delete-before --exclude-from=$LIBPATH/exclusions.lst $DOCROOTDIR/staging/$PREFIX.$ONEDOMAIN/ $DOCROOTDIR/live/$PREFIX.$ONEDOMAIN/
      nginx_conf="/etc/nginx/sites-enabled/static.$ONEDOMAIN.conf"
      if [ ! -L "$nginx_conf" ]; then
         cd /etc/nginx/sites-enabled && sudo ln -s ../sites-available/static.$ONEDOMAIN.conf && systemctl reload nginx.service
      fi
   else
      nice -n 20 rsync -avilzx --delete-before --exclude-from=$LIBPATH/exclusions.lst -e ssh $DOCROOTDIR/staging/$PREFIX.$ONEDOMAIN/ root@$i:$DOCROOTDIR/live/$PREFIX.$ONEDOMAIN/
   fi

   if [ $? = "1" ]; then
      echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation " >> $status
      exit 1
   fi
      echo " - TASK : ===== Completed publish of staging -> live for $i =====" >> $status
done

rmdir -v /tmp/.one-publish-rsync.$1.lock
echo "$(timestamp) - SUCCESS : rsync publish completed" >> $status
