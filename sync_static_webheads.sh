#!/bin/bash
# push-datasync.sh - Push one site's updates from master server to front end web servers via rsync

LIB_PATH="$HOME/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

drupal_files_list=($(ssh $APP_SERVERS_MASTER 'bash $HOME/rsyncster/drupalfiles_get.sh')) # Todo: change to standard env variable path

if [ -d /tmp/.webheads.$1.lock ]; then
   
   echo " - TASK : lock exists : Continuing sync of $1" >> $status
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

   echo "$(timestamp) - FAILURE : cannot create .webheads.lock" >> $status
   exit 1

else

   echo " - SUCCESS : created sync webheads.lock" >> $status

fi

if [ $(printf ${drupal_files_list[@]} | grep -o "$ONEDOMAIN" | wc -w) ] ; then
   

    echo "$(timestamp) - TASK : ===== Syncing sites/default/files for $ONEDOMAIN =====" >> $status
    nice -n 20 rsync -avilzx --delete-before -e ssh root@$APP_SERVERS_MASTER:$DOCROOT_DIR/kelleygraham.com/sites/default/files/$ONEDOMAIN/ $DOCROOT_DIR/live/$PREFIX.$ONEDOMAIN/sites/default/files/

    if [ $? = "1" ]; then

      echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation " >> $status
      exit 1

   fi

      echo "$(timestamp) - SUCCESS : ===== Completed rsync of sites/default/files for $drupalfiles =====" >> $status

fi

for i in ${webservers[@]}; do

   echo " - TASK : ===== Beginning rsync push of static content to webhead $i =====" >> $status

      if ! [ $i = "192.237.251.89" ]; then

         NPREFIX="static"

      else

         NPREFIX="db2.static"

      fi

      if ! ssh root@$i "test -L /var/www/html/live" ; then # check for live folder, provision if needed. Todo: add folder path to .env.sh

         echo " - NOTICE : Docroot folder not found. Configuring docroot folder for $i" >> $status
	 mkdir -v /var/www/html/live >> $status

      fi

      nice -n 20 rsync -avilzx --delete-before --exclude-from=$LIB_DIR/exclusions.lst -e ssh $DOCROOT_DIR/live/$PREFIX.$ONEDOMAIN/ root@$i:$DOCROOT_DIR/live/$PREFIX.$ONEDOMAIN/

      if ! ssh root@$i "test -L /etc/nginx/sites-enabled/$NPREFIX.$ONEDOMAIN.conf" ; then # sites-available, sites-enabled, snippets and such must be provisioned manually at this time. TODO

         echo " - TASK : Configuring nginx for $i" >> $status
         nice -n 20 rsync -avilzx -e ssh /etc/nginx/sites-available/$NPREFIX.$ONEDOMAIN.conf root@$i:/etc/nginx/sites-available/
	 ssh root@$i "cd /etc/nginx/sites-enabled && ln -s ../sites-available/$NPREFIX.$ONEDOMAIN.conf" 
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
