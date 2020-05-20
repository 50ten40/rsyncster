#!/bin/bash

aggregate_changes() {

   echo "$(timestamp) - FUNCTION - Starting aggregate_changes" >> $status
   rm /tmp/$CHANGES_STRING.lst # cleanup

   for i in $APP_SERVERS; do
   
      echo " - TASK : Getting changed domains list from $i" >> $status
      ssh root@$i "find $WORKING_DIR/ -maxdepth 1 -printf \"%f\n\"" >> /tmp/$CHANGES_STRING.lst

   done

   echo " - TASK : Aggregating changed domains list" >> $status

   if [ ! -d $WORKING_DIR ] ; then
      mkdir $WORKING_DIR
   fi

   sed -i '' s/^$PREFIX\.//g /tmp/$CHANGES_STRING.lst
   sort /tmp/$CHANGES_STRING.lst -u > $DOMAINS_FILE
   sed -i '' s/"$CHANGES_STRING\/"/""/g $DOMAINS_FILE
   sed -i '' /^$/d $DOMAINS_FILE

   for i in $APP_SERVERS; do

      if [ ! -d $WORKING_DIR/$i ] ; then

         echo " - TASK : Creating local working directories for $i" >> $status
         mkdir $WORKING_DIR/$i

      fi

      echo " - TASK : Getting pages list from $i" >> $status
      scp -p root@$i:$WORKING_DIR/* $WORKING_DIR/$i/

   done

   mapfile -t <$DOMAINS_FILE

   for d in "${MAPFILE[@]}"; do

      if [ ! -d $WORKING_DIR/$d ] ; then
      
         mkdir $WORKING_DIR/$d
      fi
		
      if [ ! -s $WORKING_DIR/$d/$PREFIX.$d ] ; then
		
         find $WORKING_DIR/$APP_SERVERS_SHORTNAME*/ -name $PREFIX.$d -print0 | xargs -0 -I file cat file > /tmp/$CHANGES_STRING.$PREFIX.$d
         sort /tmp/$CHANGES_STRING.$PREFIX.$d -u > $WORKING_DIR/$d/$PREFIX.$d

         for a in $APP_SERVERS; do

            echo " - TASK : Clearing remote changes $d from $a" >> $status
            
            if ! [ root@$a:$WORKING_DIR/$d -nt $WORKING_DIR/$a/$d ] ; then
              
                 ssh root@$a "cd $WORKING_DIR/ && rm -rf $d"
            
            fi

         done
	
      else 

         echo " - TASK : Still processing pages for $d. Update deferred. Change cron frequency?" >> $status # Comment this message.

      fi
   done
}

