#!/bin/bash
# Call from cron. Scan for changes and invoke main.sh.
# Using cookie sessions on haproxy. This script gathers changes from app servers. 

#NGINX_ENABLED_DIR="/etc/nginx/sites-enabled" # Todo: Use for sanity checks.
PREFIX="m" # Subdomain name for CMS.
CHANGES_STRING=".changes" # Identifying string used in various contexts. 
DOCROOT_DIR="/var/www/html"
MANAGE_DIR="/home/kelley/manage"
WORKING_DIR="$DOCROOT_DIR/$CHANGES_STRING"
PAGES_FILE="pages.lst"
DOMAINS_FILE="$DOCROOT_DIR/$CHANGES_STRING/domains.lst"
#SESSION_DURATION="600" # Use later when walking file timestamps.
#EVENTS_LIST="CREATE,MODIFY" #DELETE,MOVED_FROM,MOVED_TO # Use later for inotify.
RSYNCSTER_SCRIPT="$MANAGE_DIR/rsyncster/main.sh"
APP_SERVERS="cloud1int cloud2int"
APP_SERVERS_SHORTNAME="cloud"

timestamp() {
	date +"%Y-%m-%d %H:%M:%S"
}
status="$MANAGE_DIR/datasync-$CHANGES_STRING.status"

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

aggregate_changes() {

	rm /tmp/$CHANGES_STRING.lst

	for i in $APP_SERVERS; do
		echo " - TASK : Getting changed domain list on $i" >> $status
		
		ssh root@$i "find $WORKING_DIR/ -maxdepth 1 -printf \"%f\n\"" >> /tmp/$CHANGES_STRING.lst
		
	done
        	
	if [ ! -d $WORKING_DIR ] ; then
		mkdir $WORKING_DIR
        fi
	
	sed -i s/^$PREFIX\.//g /tmp/$CHANGES_STRING.lst
        sort /tmp/$CHANGES_STRING.lst -u > $DOMAINS_FILE
        sed -i s/"$CHANGES_STRING\/"/""/g $DOMAINS_FILE
        sed -i /^$/d $DOMAINS_FILE
		
	for i in $APP_SERVERS; do

		if [ ! -d $WORKING_DIR/$i ] ; then
                	mkdir $WORKING_DIR/$i
	      	fi
                echo " - TASK : Getting changed files listing on $i" >> $status
		scp root@$i:$WORKING_DIR/* $WORKING_DIR/$i/
	done
		
	mapfile -t <$DOMAINS_FILE

	for d in "${MAPFILE[@]}"; do
			
		if [ ! -d $WORKING_DIR/$d ] ; then
	         	mkdir $WORKING_DIR/$d
        	fi
			
		find $WORKING_DIR/$APP_SERVERS_SHORTNAME*/ -name $PREFIX.$d -print0 | xargs -0 -I file cat file > $WORKING_DIR/$d/$PREFIX.$d
		sort $WORKING_DIR/$d/$PREFIX.$d -u > $WORKING_DIR/$d/$PREFIX.$d
	done	
}	

sync() {
	
	mapfile -t <$DOMAINS_FILE
	#source $RSYNCSTER_SCRIPT "${MAPFILE[@]}"

	for i in "${MAPFILE[@]}"; do
		
		START_TIME=`echo $(($(date +%s%N/1000000000)))`
		$RSYNCSTER_SCRIPT $i cron
		END_TIME=`echo $(($(date +%s%N/1000000000)))`
		ELAPSED_TIME=$(($END_TIME - $START_TIME))
		echo "$(timestamp) - SUCCESS : Sync of $i completed in $ELAPSED_TIME seconds" >> $status

		for f in $APP_SERVERS; do
                	ssh root@$f "rm $WORKING_DIR/m.$i"
			echo "$TIMESTAMP - TASK : Removing $i from $WORKING_DIR on $f" >> $status
		done		
	done
}

aggregate_changes

echo " - TASK : Getting merged changes list in local path $WORKING_DIR" >> $status

if test -n "$(find $WORKING_DIR/ -maxdepth 1 -empty)"; then
	
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

#cat $status

#watch() {
#  inotifywait -e "$EVENTS_LIST" -m -r --format '%:e %f' $DOCROOT_DIR/$CHANGES_DIR/ # todo: test management by incron. 
#}

#watch | ( 
#while true ; do
#  read -t 1 LINE && sync
#done
#)
