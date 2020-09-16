#!/bin/bash
# Call from cron. Scan for changes and invoke main.sh.
# Using cookie sessions on haproxy. This script gathers changes from app servers. 

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_aggregate_changes.sh
. $LIBPATH/function_sync.sh
. $LIBPATH/function_timestamp.sh

# Housekeeping

if [ ! -d /tmp/$CHANGESSTRING.lock ]; then

   /bin/mkdir /tmp/$CHANGESSTRING.lock

fi

if [ $? = "1" ]; then

   echo "$(timestamp) - FAILURE : unable to create $CHANGESSTRING.lock" >> $status	

else

   echo "$(timestamp) - SUCCESS : created $CHANGESSTRING.lock" > $status

fi

if [ ! -d $LOGDIR ]; then

      /bin/mkdir $LOGDIR

fi

if [ $? = "1" ]; then

   echo "$(timestamp) - FAILURE : unable to create $LOGDIR" >> $status

else

   echo "$(timestamp) - SUCCESS : created $LOGDIR" >> $status

fi

if [ $DEBUG = "yes" ]; then
   echo "$(timestamp) - TEST : cron_get_changes.sh - staging directory is $STAGINGDIR" >> $status
fi

# Call function to get changes from APPSERVER(S)

aggregate_changes

if [ -d /tmp/$CHANGESSTRING.lock ]; then

   echo " - TASK : Updating merged changes list in local path $WORKINGDIR" >> $status

else

   echo " - TASK : Getting merged changes list in local path $WORKINGDIR" >> $status

fi

if [ -f $DOMAINSFILE ] && [ ! -s $DOMAINSFILE ] ; then	

   echo "$(timestamp) - FUNCTION : No changes, exiting" >> $status	
   /bin/rmdir /tmp/$CHANGESSTRING.lock
	
   if [ $? = "1" ]; then

      echo "$(timestamp) - FAILURE : Unable to delete $CHANGESSTRING.lock" >> $status
      exit 1
	
   else
        
      echo "$(timestamp) - SUCCESS : Deleted $CHANGESSTRING.lock" >> $status
      exit 1
   fi

else 

   echo "$(timestamp) - SUCCESS : Syncing changes list" >> $status
   { time -p sync ; } 2>> $status
   /bin/rmdir /tmp/$CHANGESSTRING.lock
   
   if [ $? = "1" ]; then

      echo "$(timestamp) - FAILURE : Unable to delete $CHANGESSTRING.lock" >> $status

   else

      echo "$(timestamp) - SUCCESS : Deleted $CHANGESSTRING.lock" >> $status

   fi
fi
