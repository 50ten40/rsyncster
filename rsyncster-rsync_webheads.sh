#!/bin/bash
# push-datasync.sh - Push updates to public webheads via rsync

webservers=(webhead1,webhead2,webhead3)
status="/tmp/datasync-rack-$1.status"

if [ -d /tmp/.one-rack-rsync.lock ]; then
echo "FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." > $status
exit 1
fi

if [ $1 ]; then

        ONEDOMAIN=$1
else
        echo -e "\n\tERROR: You must include a domain name on the command line when invoking this script.\n"
        exit
fi

mkdir -v /tmp/.one-rack-rsync.lock

if [ $? = "1" ]; then
echo "FAILURE : cannot create lock" > $status
exit 1
else
echo "SUCCESS : created lock" > $status
fi

for i in ${webservers[@]}; do

echo "===== Beginning rsync of static docroot on $i ====="

# assume that key based security is setup.
nice -n 20 /usr/bin/rsync -avilzx --delete-before -e ssh /var/www/html/live/m.$ONEDOMAIN/ webuser@$i:/var/www/html/live/m.$ONEDOMAIN/
nice -n 20 /usr/bin/rsync -avilzx -e ssh /etc/nginx/sites-available/static.$ONEDOMAIN.conf webuser@$i:/etc/nginx/sites-available/

# uncomment and edit to taste to automate nginx config activation 
#ssh remote command to setup symlink into sites-enabled
#ssh root@$i "sudo systemctl condreload nginx"
#ssh root@$i "systemctl status nginx"

if [ $? = "1" ]; then
echo "FAILURE : rsync failed. Please refer to the solution documentation " > $status
exit 1
fi

echo "===== Completed rsync of http docroot on $i =====";
done

rmdir -v /tmp/.one-rack-rsync.lock

echo "SUCCESS : rsync completed successfully" > $status
