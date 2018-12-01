#!/bin/bash
# Call from cron. Scan for changes and invoke main.sh.
# Using cookie sessions on haproxy. This script gathers changes from app servers. 

LIB_PATH="$HOME/manage/rsyncster/lib"
. $LIB_PATH/env.sh
. $LIB_PATH/function_aggregate_changes.sh
. $LIB_PATH/function_sync.sh
. $LIB_PATH/function_timestamp.sh

if [ -d /tmp/$CHANGES_STRING.lock ]; then
	echo "$(timestamp) - FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon."
	exit 1
fi

/bin/mkdir /tmp/$CHANGES_STRING.lock

if [ $? = "1" ]; then
	echo "$(timestamp) - FAILURE : cannot create lock" > $status
	exit 1
else
	echo "$(timestamp) - SUCCESS : created lock" > $status
fi

aggregate_changes

echo " - TASK : Getting merged changes list in local path $WORKING_DIR" >> $status

if [ -f $DOMAINS_FILE ] && [ ! -s $DOMAINS_FILE ] ; then
	
	echo "$(timestamp) - SUCCESS : No changes, exiting" >> $status
	/bin/rmdir /tmp/$CHANGES_STRING.lock
	
	if [ $? = "1" ]; then
        	echo "$(timestamp) - FAILURE : cannot delete lock" >> $status
        	exit 1
	else
        	echo "$(timestamp) - SUCCESS : deleted lock" >> $status
		exit 1
	fi

else 
	echo "$(timestamp) - SUCCESS : Syncing changes." >> $status
fi

sync

/bin/rmdir /tmp/$CHANGES_STRING.lock

if [ $? = "1" ]; then

        echo "$(timestamp) - FAILURE : cannot delete lock" >> $status
        exit 1

else

        echo "$(timestamp) - SUCCESS : deleted lock" >> $status

fi
