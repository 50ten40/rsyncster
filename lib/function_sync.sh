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
      
      #START_TIME=`echo $(($(date +%s%N/1000000000)))` # not portable for default *nix shell, using time keyword when calling sync().
      $RSYNCSTER_SCRIPT $i upgrade # passing upgrade command. future default pulls only changed items using listicle feature, eg only get what's changed.
      #END_TIME=`echo $(($(date +%s%N/1000000000)))`
      #ELAPSED_TIME=$(($END_TIME - $START_TIME))
      
      echo "$(timestamp) - FUNCTION : Sync of $i completed. Execution stats displayed in console" >> $status 
      
      /bin/rmdir /tmp/$CHANGES_STRING.sync.$i.lock
      echo "$(timestamp) - SUCCESS : Deleted $CHANGES_STRING.sync.$i.lock" >> $status

   done
}
