#!/bin/bash

LIB_PATH="$HOME/manage/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_timestamp.sh

if [ "$2" == "upgrade" ]; then

   echo "$(timestamp) - TASK : Starting CMS cache flush." >> $status
	
   if sudo ssh $APP_SERVERS_MASTER "test -e $DOCROOT_DIR/$1"; then

      sudo ssh $APP_SERVERS_MASTER "drush use $DOCROOT_DIR/$1#default && drush cc all"
	
   else
	
      sudo ssh $APP_SERVERS_MASTER "drush use $DOCROOT_DIR/kelleygraham.com/#$1 && drush cc all"
	
   fi

   echo "$(timestamp) - SUCCESS : Completed CMS cache flush." >> $status

fi

sudo $MANAGE_DIR/rsyncster/wget_static_drupal.pl $1 && sudo $MANAGE_DIR/rsyncster/publish.sh $1 && sudo $MANAGE_DIR/rsyncster/sync_static_webheads.sh $1
