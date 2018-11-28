#!/bin/bash

MANAGE_DIR="/home/kelley/manage"
status="$MANAGE_DIR/datasync-changes.status"
timestamp() {
        date +"%Y-%m-%d %H:%M:%S"
}

if [ $2 ne "cron" ]; then

	echo " - TASK : Starting CMS cache flush." >> $status
	
	if sudo ssh cloud2int "test -e /var/www/html/$1"; then
		sudo ssh cloud2int "drush use /var/www/html/$1#default && drush cc all"
	else
		sudo ssh cloud2int "drush use /var/www/html/kelleygraham.com/#$1 && drush cc all"
	fi

echo "$(timestamp) - SUCCESS : Completed CMS cache flush." >> $status

fi

sudo $MANAGE_DIR/rsyncster/wget_static_drupal.pl $1 && sudo $MANAGE_DIR/rsyncster/publish.sh $1 && sudo $MANAGE_DIR/rsyncster/sync_static_webheads.sh $1
