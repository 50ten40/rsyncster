#!/bin/bash

sync() {

   mapfile -t <$DOMAINSFILE

   for i in "${MAPFILE[@]}"; do
		
      if [ -d /tmp/$CHANGESSTRING.$i.lock ]; then
        	
         echo " - TASK : Still processing changes for $i" >> $status
         break;

      else

         /bin/mkdir /tmp/$CHANGESSTRING.sync.$i.lock
         echo "$(timestamp) - FUNCTION : Created $CHANGESSTRING.sync.$i.lock" >> $status

      fi

      echo " - TASK : Sync of $i" started >> $status
      
      #STARTTIME=`echo $(($(date +%s%N/1000000000)))` # not portable for default *nix shell, using time keyword when calling sync().
      $RSYNCSTERSCRIPT $i upgrade # passing upgrade command. future default pulls only changed items using listicle feature, eg only get what's changed.
      #ENDTIME=`echo $(($(date +%s%N/1000000000)))`
      #ELAPSEDTIME=$(($ENDTIME - $STARTTIME))
      
      echo "$(timestamp) - FUNCTION : Sync of $i completed." >> $status 
      
      /bin/rmdir /tmp/$CHANGESSTRING.sync.$i.lock
      echo "$(timestamp) - SUCCESS : Deleted $CHANGESSTRING.sync.$i.lock" >> $status

   done
}
