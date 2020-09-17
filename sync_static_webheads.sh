#!/bin/bash
# push-datasync.sh - Push one site's updates from master server to front end web servers via rsync

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_timestamp.sh

drupal_files_list=($(ssh $APPSERVERSMASTER 'bash $HOME/rsyncster/drupalfiles_get.sh'))

if [ -d /tmp/.webheads.$1.lock ]; then
   
   echo " - NOTICE : /tmp/.webheads.$1.lock exists : If developing, do you need to remove? Otherwise, sync continues" >> $status
   cat $status
   exit 1

fi

if [ $1 ]; then

   ONEDOMAIN=$1

else

   echo -e "\n\tERROR: You must include a domain name on the command line when invoking this script.\n"
   exit

fi

mkdir -v /tmp/.webheads.$1.lock

if [ $? = "1" ]; then

   echo "$(timestamp) - FAILURE : cannot create .webheads.$1.lock" >> $status
   exit 1

else

   echo " - SUCCESS : created sync webheads.$1.lock" >> $status

fi

if [ $(printf ${drupal_files_list[@]} | grep -o "$ONEDOMAIN" | wc -w) ] ; then # need to add logic for finding drupal root path for standalone sites
   

    echo "$(timestamp) - TASK : ===== Syncing sites/default/files for $ONEDOMAIN =====" >> $status
    nice -n 20 rsync -avilzx --delete-before -e ssh root@$APPSERVERSMASTER:$DOCROOTDIR/kelleygraham.com/sites/default/files/$ONEDOMAIN/ $DOCROOTDIR/live/$PREFIX.$ONEDOMAIN/sites/default/files/

    if [ $? = "1" ]; then

      echo "$(timestamp) - FAILURE : Failed rsync of sites/default/files for $ONEDOMAIN. Please refer to the solution documentation " >> $status
      exit 1

   fi

      echo "$(timestamp) - SUCCESS : ===== Completed rsync of sites/default/files for $ONEDOMAIN =====" >> $status

fi

for i in ${webservers[@]}; do

   echo " - TASK : ===== Beginning rsync push of static content to webhead $i =====" >> $status

      if [ $i = "192.237.251.89" ]; then # for webservers behind haproxy listening on localhost.

         HAPREFIX="db2"

      fi

      if ! ssh root@$i "test -L $LIVEDIR || test -d $LIVEDIR" ; then # check for live folder, provision if needed.

         echo " - NOTICE : Docroot folder not found. Configuring docroot folder for $i" >> $status
	 mkdir -v $LIVEDIR >> $status

      fi

      nice -n 20 rsync -avilzx --delete-before --exclude-from=$LIBDIR/exclusions.lst -e ssh $LIVEDIR/$PREFIX.$ONEDOMAIN/ root@$i:$LIVEDIR/$PREFIX.$ONEDOMAIN/

      if "[ -d "/etc/nginx" ]"; then
         echo " - NOTICE : Found local linux nginx config dir on $i" >> $status
         LOCAL_NGINX_PATH="/etc/nginx"
         LOCAL_NGINX_CMD="systemctl condreload nginx" # cmd(s) currently unused
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

      if ! ssh root@$i "test -e $REMOTE_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf"; then # basic nginx provisioning must be complete. Later autoprovision. 

         echo " - TASK : Configuring nginx for $i" >> $status

	 if ! [ -e "$LOCAL_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf" ] ; then # test for local file
            sed -e 's/\([[:space:]]\)80/\1127.0.0.1\:80/g' $LOCAL_NGINX_PATH/sites-available/$NPREFIX.$ONEDOMAIN.conf > $LOCAL_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf # create file if not exists
            sed -ie 's/]/1]/g' $LOCAL_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf
         fi

         nice -n 20 rsync -avilzx -e ssh $LOCAL_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf root@$i:$REMOTE_NGINX_PATH/sites-available/
	 ssh root@$i "cd $REMOTE_NGINX_PATH/sites-enabled && ln -s ../sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf" 
         ssh root@$i "service nginx reload"
         ssh root@$i "service nginx status"

      fi

   if [ $? = "1" ]; then

      echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation " >> $status
      exit 1

   fi

      echo " - TASK : ===== Completed rsync push of static content to webhead $i =====" >> $status

done

rmdir -v /tmp/.webheads.$1.lock
echo "$(timestamp) - SUCCESS : removed sync webheads.lock" >> $status
