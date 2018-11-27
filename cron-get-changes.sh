#!/bin/bash
# Call from cron. Scan for changes and invoke rsynster.
# Using cookie sessions on haproxy. This script gathers changes from app servers. 

#NGINX_ENABLED_DIR="/etc/nginx/sites-enabled" # Todo: Use for sanity checks.
CHANGES_FILE="sites.lst"
CHANGES=".changes"
DOCROOT_DIR="/var/www/html"
MANAGE_DIR="/home/kelley/manage"
#SESSION_DURATION="600" # Use later when walking file timestamps.
#EVENTS_LIST="CREATE,MODIFY" #DELETE,MOVED_FROM,MOVED_TO # Use later for inotify
RSYNCSTER_SCRIPT="$MANAGE_DIR/rsyncster/main.sh"
APP_SERVERS="cloud1int cloud2int"

status="$MANAGE_DIR/datasync-changes.status"

if [ -d /tmp/.changes.lock ]; then
	echo "FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." > $status
	exit 1
fi

/bin/mkdir /tmp/.changes.lock

if [ $? = "1" ]; then
	echo "FAILURE : cannot create lock" > $status
	exit 1
else
	echo "SUCCESS : created lock" > $status
fi

aggregate_changes() {

	rm /tmp/$CHANGES

  	for i in $APP_SERVERS; do
		echo "TASK : Getting changes on $i" >> $status	
		ssh root@$i "find $DOCROOT_DIR/$CHANGES -maxdepth 1 -printf \"%f\n\"" >> /tmp/$CHANGES
	done
	
	sed -i s/^m.//g /tmp/$CHANGES
	if [ ! -d $DOCROOT_DIR/$CHANGES ] ; then
		mkdir $DOCROOT_DIR/$CHANGES
	fi
	sort /tmp/$CHANGES -u > $DOCROOT_DIR/$CHANGES/$CHANGES_FILE
	sed -i s/$CHANGES//g $DOCROOT_DIR/$CHANGES/$CHANGES_FILE
	sed -i /^$/d $DOCROOT_DIR/$CHANGES/$CHANGES_FILE
	cat $DOCROOT_DIR/$CHANGES/$CHANGES_FILE
}

sync() {
	
	mapfile -t <$DOCROOT_DIR/$CHANGES/$CHANGES_FILE
	#source $RSYNCSTER_SCRIPT "${MAPFILE[@]}"

	for i in "${MAPFILE[@]}"; do
		
		SECONDS=0

		$RSYNCSTER_SCRIPT $i
		
		echo "SUCCESS : Sync of $i in date +%T -d "1/1 + SECONDS sec"" >> $status

		for f in $APP_SERVERS; do
                	ssh root@$f "rm $DOCROOT_DIR/$CHANGES/m.$i"
			echo "TASK : Removing $i from $DOCROOT_DIR/$CHANGES on $f" >> $status
		done		
	done
}

aggregate_changes

if test -n "$(find $DOCROOT_DIR/$CHANGES -maxdepth 1 -empty)"; then
	echo "SUCCESS : No changes, exiting." >> $status
	/bin/rmdir /tmp/.changes.lock
	if [ $? = "1" ]; then
        	echo "FAILURE : cannot delete lock" >> $status
        	exit 1
	else
        	echo "SUCCESS : deleted lock" >> $status
		exit 1
	fi

else 
	echo "SUCCESS : Syncing changes." >> $status
fi

sync

/bin/rmdir /tmp/.changes.lock

if [ $? = "1" ]; then
        echo "FAILURE : cannot delete lock" >> $status
        exit 1
else
        echo "SUCCESS : deleted lock" >> $status
fi

cat $status

#watch() {
#  inotifywait -e "$EVENTS_LIST" -m -r --format '%:e %f' $DOCROOT_DIR/$CHANGES_DIR/ # todo: test management by incron. 
#}

#watch | ( 
#while true ; do
#  read -t 1 LINE && sync
#done
#)
