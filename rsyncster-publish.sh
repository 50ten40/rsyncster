#!/bin/bash
# push-datasync.sh - Push one site's updates from master server to front end web servers via rsync

webservers=(localhost) #may have multiple staging locations, (your workflow may vary)
status="/tmp/datasync-publish-$1.status"

if [ -d /tmp/.one-publish-rsync.lock ]; then
echo "FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." > $status
exit 1
fi

if [ $1 ]; then

        ONEDOMAIN=$1
else
        echo -e "\n\tERROR: You must include a domain name on the command line when invoking this script.\n"
        exit
fi

mkdir -v /tmp/.one-publish-rsync.lock

if [ $? = "1" ]; then
echo "FAILURE : cannot create lock" > $status
exit 1
else
echo "SUCCESS : created lock" > $status
fi


for i in ${webservers[@]}; do

echo "===== Beginning publish of static docroot on $i ====="

if [ $i = "localhost" ]; then
	nice -n 20 /usr/bin/rsync -avilzx --delete-before /var/www/html/staging/m.$ONEDOMAIN/ /var/www/html/live/m.$ONEDOMAIN/
else
	nice -n 20 /usr/bin/rsync -avilzx --delete-before -e ssh /var/www/html/staging/m.$ONEDOMAIN/ root@$i/var/www/html/live/m.$ONEDOMAIN/
fi

if [ $? = "1" ]; then
echo "FAILURE : rsync failed. Please refer to the solution documentation " > $status
exit 1
fi

echo "===== Completed publish of staging -> live for $i =====";
done

rmdir -v /tmp/.one-publish-rsync.lock

echo "SUCCESS : rsync completed successfully" > $status
