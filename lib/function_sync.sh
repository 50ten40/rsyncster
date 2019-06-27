#!/bin/bash

sync() {

   mapfile -t <$DOMAINS_FILE

   for i in "${MAPFILE[@]}"; do
		
      if [ -d /tmp/$CHANGES_STRING.$i.lock ]; then
        	
         echo " - TASK : Still processing changes for $i" >> $status
         break;

      else

         /bin/mkdir /tmp/$CHANGES_STRING.sync.$i.lock
         echo "$(timestamp) - FUNCTION : Created $CHANGES_STRING.sync.$i.lock" >> $status

      fi

      echo " - TASK : Sync of $i" started >> $status
      
      START_TIME=`echo $(($(date +%s%N/1000000000)))`
      $RSYNCSTER_SCRIPT $i upgrade #cron individual pages listicle feature broke for now.
      END_TIME=`echo $(($(date +%s%N/1000000000)))`
      ELAPSED_TIME=$(($END_TIME - $START_TIME))
      
      echo "$(timestamp) - FUNCTION : Sync of $i completed in $ELAPSED_TIME seconds" >> $status
      
      /bin/rmdir /tmp/$CHANGES_STRING.sync.$i.lock
      echo "$(timestamp) - SUCCESS : Deleted $CHANGES_STRING.sync.$i.lock" >> $status

   done
}
