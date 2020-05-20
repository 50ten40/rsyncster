#!/bin/bash

LIB_PATH="$HOME/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

if [ $DRUPAL_CACHE == "On" ]; then
 
   if [ "$2" == "upgrade" ]; then
      echo "$(timestamp) - TASK : Starting CMS cache flush." >> $status

      if sudo ssh $APP_SERVERS_MASTER "test -e $DOCROOT_DIR/$1"; then
         sudo ssh $APP_SERVERS_MASTER "drush use $DOCROOT_DIR/$1#default && drush cc all"

      else

         sudo ssh $APP_SERVERS_MASTER "drush use $DOCROOT_DIR/kelleygraham.com/#$1 && drush cc all"	

      fi

      echo "$(timestamp) - SUCCESS : Completed CMS cache flush." >> $status

   fi

else
      
      echo "$(timestamp) - NOTICE : Skipping CMS cache flush." >> $status

fi

$HOME/rsyncster/wget_static_drupal.pl $1 && $HOME/rsyncster/publish.sh $1 && $HOME/rsyncster/sync_static_webheads.sh $1
