#!/bin/bash

aggregate_changes() {

   echo "$(timestamp) - FUNCTION - Starting aggregate_changes" >> $status
   rm /tmp/$CHANGESSTRING.lst # cleanup

   for i in $APPSERVERS; do
   
      echo " - TASK : Getting changed domains list from $i" >> $status
      ssh root@$i "find $WORKINGDIR/ -maxdepth 1 -printf \"%f\n\"" >> /tmp/$CHANGESSTRING.lst

   done

   echo " - TASK : Aggregating changed domains list" >> $status

   if [ ! -d $WORKINGDIR ] ; then
      mkdir $WORKINGDIR
   fi

   sed -i '' s/^$PREFIX\.//g /tmp/$CHANGESSTRING.lst
   sort /tmp/$CHANGESSTRING.lst -u > $DOMAINSFILE
   sed -i '' s/"$CHANGESSTRING\/"/""/g $DOMAINSFILE
   sed -i '' /^$/d $DOMAINSFILE

   for i in $APPSERVERS; do

      if [ ! -d $WORKINGDIR/$i ] ; then

         echo " - TASK : Creating local working directories for $i" >> $status
         mkdir $WORKINGDIR/$i

      fi

      echo " - TASK : Getting pages list from $i" >> $status
      scp -p root@$i:$WORKINGDIR/* $WORKINGDIR/$i/

   done

   mapfile -t <$DOMAINSFILE

   for d in "${MAPFILE[@]}"; do

      if [ ! -d $WORKINGDIR/$d ] ; then
      
         mkdir $WORKINGDIR/$d
      fi
		
      if [ ! -s $WORKINGDIR/$d/$PREFIX.$d ] ; then
		
         find $WORKINGDIR/$APPSERVERSSHORTNAME*/ -name $PREFIX.$d -print0 | xargs -0 -I file cat file > /tmp/$CHANGESSTRING.$PREFIX.$d
         sort /tmp/$CHANGESSTRING.$PREFIX.$d -u > $WORKINGDIR/$d/$PREFIX.$d

         for a in $APPSERVERS; do

            echo " - TASK : Clearing remote changes $d from $a" >> $status
            
            if ! [ root@$a:$WORKINGDIR/$d -nt $WORKINGDIR/$a/$d ] ; then
              
                 ssh root@$a "cd $WORKINGDIR/ && rm -rf $d"
            
            fi

         done
	
      else 

         echo " - TASK : Still processing pages for $d. Update deferred. Change cron frequency?" >> $status # Comment this message.

      fi
   done
}
