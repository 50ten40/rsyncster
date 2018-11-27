#!/bin/bash
	
if sudo ssh cloud2int "test -e /var/www/html/$1"; then
	sudo ssh cloud2int "drush use /var/www/html/$1#default && drush cc all"
else
	sudo ssh cloud2int "drush use /var/www/html/kelleygraham.com/#$1 && drush cc all"
fi

sudo ./wget_static_drupal.pl $1 && sudo ./publish.sh $1 && sudo ./sync_static_webheads.sh $1
