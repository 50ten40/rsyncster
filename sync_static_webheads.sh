#!/bin/bash
# push-datasync.sh - Push one site's updates from master server to front end web servers via rsync

LIB_PATH="$HOME/manage/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

webservers=(192.237.251.89) #todo: get from .env.sh - we do not rely on syncthing due to delay on publish. eg staging->live.

ssh cloud2int cd /var/www/html/kelleygraham.com/sites && shopt -s dotglob && shopt -s nullglob && drupalfiles=(*/)

#status="$MANAGE_DIR/datasync-webheads-$1.status"

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



for i in ${webservers[@]}; do

<<<<<<< HEAD
   echo " - TASK : ===== Beginning rsync push of  static content to webhead $i =====" >> $status
=======
   echo " - TASK : ===== Beginning rsync push of static content to webhead $i =====" >> $status
>>>>>>> 38cb671247714a877a909ce7a17d6aab66bb1f23

      if ! [ $i = "192.237.251.89" ]; then

         NPREFIX="static"

      else

         NPREFIX="db2.static"

      fi

<<<<<<< HEAD
      nice -n 20 rsync -avilzx --delete-before --exclude-from=$LIB_PATH/exclusions.lst -e ssh $DOCROOT_DIR/live/$PREFIX.$ONEDOMAIN/ root@$i:$DOCROOT_DIR/live/$PREFIX.$ONEDOMAIN/

      if ! ssh root@$i "test -L /etc/nginx/sites-enabled/$NPREFIX.$ONEDOMAIN.conf"; then

         echo " - TASK : Configuring nginx for $i" >> $status
         nice -n 20 rsync -avilzx -e ssh /etc/nginx/sites-available/$NPREFIX.$ONEDOMAIN.conf root@$i:/etc/nginx/sites-available/
	 ssh root@$i "cd /etc/nginx/sites-enabled && ln -s ../sites-available/$NPREFIX.$ONEDOMAIN.conf" 
         ssh root@$i "systemctl condreload nginx"
         ssh root@$i "systemctl status nginx"

=======
      nice -n 20 rsync -avilzx --delete-before --exclude-from=$LIB_DIR/exclusions.lst -e ssh $DOCROOT_DIR/live/$PREFIX.$ONEDOMAIN/ root@$i:$DOCROOT_DIR/live/$PREFIX.$ONEDOMAIN/

      if ! ssh root@$i "test -L /etc/nginx/sites-enabled/$NPREFIX.$ONEDOMAIN.conf"; then

         echo " - TASK : Configuring nginx for $i" >> $status
         nice -n 20 rsync -avilzx -e ssh /etc/nginx/sites-available/$NPREFIX.$ONEDOMAIN.conf root@$i:/etc/nginx/sites-available/
	 ssh root@$i "cd /etc/nginx/sites-enabled && ln -s ../sites-available/$NPREFIX.$ONEDOMAIN.conf" 
         ssh root@$i "systemctl condreload nginx"
         ssh root@$i "systemctl status nginx"

>>>>>>> 38cb671247714a877a909ce7a17d6aab66bb1f23
      fi

   if [ $? = "1" ]; then

      echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation " >> $status
      exit 1

   fi

      echo " - TASK : ===== Completed rsync push of static content to webhead $i =====" >> $status

done

rmdir -v /tmp/.webheads.$1.lock
echo "$(timestamp) - SUCCESS : removed sync webheads.lock" >> $status
