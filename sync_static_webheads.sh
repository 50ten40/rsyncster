#!/bin/bash
# push-datasync.sh - Push one site's updates from master server to front end web servers via rsync

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_timestamp.sh

drupalfiles_list=($(ssh $APPSERVERSMASTER 'bash $HOME/rsyncster/drupalfiles_get.sh'))

if [ -d /tmp/.webheads.$1.lock ]; then
   
   echo " - NOTICE : /tmp/.webheads.$1.lock exists : If developing, do you need to remove? Otherwise, sync continues" >> $status
   cat $status | grep NOTICE
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

for i in ${webservers[@]}; do

   echo " - TASK : ===== Beginning rsync push of static content to webhead $i =====" >> $status

      if [ $i = "192.237.251.89" ]; then # for webservers behind haproxy listening on localhost.

         HAPREFIX="db2"

      fi

      if ! ssh root@$i "test -L $LIVEDIR || test -d $LIVEDIR" ; then # check for live folder, provision if needed.

         echo " - NOTICE : Docroot folder not found. Configuring docroot folder for $i" >> $status
	 mkdir -v $LIVEDIR >> $status

      fi

      echo "$(timestamp) - TASK : =====  Syncing $LIVEDIR for $ONEDOMAIN =====" >> $status
      rsync -avilzx --delete-before --exclude-from=$LIBDIR/exclusions.lst -e ssh $LIVEDIR/$PREFIX.$ONEDOMAIN/ root@$i:$LIVEDIR/$PREFIX.$ONEDOMAIN/

      if ! [ $(printf ${drupalfiles_list[@]} | grep -o "$ONEDOMAIN" | wc -w) ] ; then
         
         echo " - FAILURE - Domain must exist" >> $status
         cat $status | grep FAILURE
         exit 1
         
      else
      
         echo "$(timestamp) - TASK : ===== Syncing drupalfiles for $ONEDOMAIN =====" >> $status

         if [ "$ONEDOMAIN" = "$DRUPAL_MULTISITE_DOMAIN" ] ; then

            echo " - NOTICE - $1 is Drupal Primary Multisite" >> $status 
            DRUPALFILES_ROOT="$DOCROOTDIR/$ONEDOMAIN"
            MULTI_PATH=""

         elif [[ ${DRUPAL_DEV_DOMAINS[@]} =~ $ONEDOMAIN ]]; then

            echo " - NOTICE - $1 is Drupal Development or Standalone site" >> $status
            DRUPALFILES_ROOT="$DOCROOTDIR/$ONEDOMAIN"
            MULTI_PATH=""

         else

            echo " - NOTICE - $1 is Drupal subsite under $DRUPAL_MULTISITE_DOMAIN" >> $status
            DRUPALFILES_ROOT="$DOCROOTDIR/$DRUPAL_MULTISITE_DOMAIN"
	    MULTI_PATH="$ONEDOMAIN/"

         fi

         DRUPALFILES_PATH=($(ssh $APPSERVERSMASTER "bash $HOME/rsyncster/drupalfiles_path.sh $ONEDOMAIN"))
         echo " - NOTICE - DRUPALFILES_PATH is set to $DRUPALFILES_PATH" >> $status
         echo " - NOTICE - DRUPALFILES_DESTINATION is set to $LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPAL_WEBHEAD_PATH/$MULTI_PATH" >> $status

	 if ! [[ -d $LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPAL_WEBHEAD_PATH ]] ; then 
	    
 	    echo " - NOTICE - $LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPALFILES_PATH not found, creating" >> $status        
	    mkdir -pv $LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPALFILES_PATH >> $status
	 
	 fi
	
         if [ $DEBUG="yes" ] ; then
            cat $status | grep NOTICE
         fi

	 rsync -avilzx --delete-before -e ssh root@$APPSERVERSMASTER:$DRUPALFILES_ROOT/$DRUPALFILES_PATH/ $LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPAL_WEBHEAD_PATH/$MULTI_PATH

         if [ $? = "1" ]; then
             echo "$(timestamp) - FAILURE : Failed rsync of $DRUPALFILES_PATH for $ONEDOMAIN. Please refer to the solution documentation" >> $status
             exit 1
         fi

         if ! ssh root@$i "[[ -d $LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPAL_WEBHEAD_PATH ]]"; then

            echo " - NOTICE - remote dir $i:$LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPALFILES_PATH not found, creating" >> $status
            ssh root@$i "mkdir -pv $LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPALFILES_PATH" >> $status
            
            if [ $DEBUG="yes" ] ; then
               cat $status | grep NOTICE
            fi
         fi

         rsync -avilzx --delete-before $LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPAL_WEBHEAD_PATH/$MULTI_PATH -e ssh root@$i:$LIVEDIR/$PREFIX.$ONEDOMAIN/$DRUPAL_WEBHEAD_PATH/$MULTI_PATH

         echo "$(timestamp) - SUCCESS : ===== Completed rsync of $DRUPALFILES_PATH for $ONEDOMAIN =====" >> $status

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

      if ! ssh root@$i "test -e $REMOTE_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf"; then # basic nginx provisioning must be complete. Later autoprovision. 

         echo " - TASK : Configuring nginx for $i" >> $status

	 if ! [ -e "$LOCAL_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf" ] ; then # test for local file
            sed -E 's/([[:space:]])80/\1127.0.0.1\:80/g' $LOCAL_NGINX_PATH/sites-available/$NPREFIX.$ONEDOMAIN.conf > $LOCAL_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf # create file if not exists
            sed -i 's/]/1]/g' $LOCAL_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf
         fi

         rsync -avilzx -e ssh $LOCAL_NGINX_PATH/sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf root@$i:$REMOTE_NGINX_PATH/sites-available/
	 ssh root@$i "cd $REMOTE_NGINX_PATH/sites-enabled && ln -s ../sites-available/$HAPREFIX$NPREFIX.$ONEDOMAIN.conf"
         ssh root@$i "service nginx reload" >> $status
         ssh root@$i "service nginx status" >> $status

         if [ $DEBUG="yes" ] ; then
            cat $status | grep nginx
         fi
      fi

   if [ $? = "1" ]; then

      echo "$(timestamp) - FAILURE : rsync failed. Please refer to the solution documentation" >> $status
      if [ $DEBUG="yes" ] ; then
         cat $status | grep FAILURE
         exit 1
      fi
   fi

      echo " - NOTICE : ===== Completed rsync push of static content to webhead $i =====" >> $status

done

rmdir -v /tmp/.webheads.$1.lock
echo "$(timestamp) - SUCCESS : removed sync webheads.lock" >> $status

if [ $DEBUG="yes" ] ; then
   echo -e "============= DEBUG LOG =============\n"
   cat $status
fi
