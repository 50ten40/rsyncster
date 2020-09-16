#!/bin/bash

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_timestamp.sh

if [ $DRUPALCACHE == "On" ]; then
 
   if [ "$2" == "upgrade" ]; then
      echo "$(timestamp) - TASK : Starting CMS cache flush." >> $status

      if sudo ssh $APPSERVERSMASTER "test -e $DOCROOTDIR/$1"; then
         sudo ssh $APPSERVERSMASTER "drush use $DOCROOTDIR/$1#default && drush cc all"

      else

         sudo ssh $APPSERVERSMASTER "drush use $DOCROOTDIR/kelleygraham.com/#$1 && drush cc all"	

      fi

      echo "$(timestamp) - SUCCESS : Completed CMS cache flush." >> $status

   fi

else
      
      echo "$(timestamp) - NOTICE : Skipping CMS cache flush." >> $status

fi

$HOME/rsyncster/wget_static_drupal.pl $1 && $HOME/rsyncster/publish.sh $1 && $HOME/rsyncster/sync_static_webheads.sh $1
