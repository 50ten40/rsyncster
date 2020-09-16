#!/bin/bash
# This helper script get domains list from primary APPSERVER

ignore_files=(all default kelleygraham.com permatecture.pro faf.photos braingurus.com signup.fafchat.com signup.faf.chat signup.faf.photos rodpweiss.com signup.faf.social signup.mastery.chat)

if [ -d "/var/www/html/kelleygraham.com/sites" ] ; then # check if we are on an appserver
   cd /var/www/html/kelleygraham.com/sites
   shopt -s dotglob 
   shopt -s nullglob
   drupalfiles=(*/)
else
   echo "Please run on primary APPSERVER"
   exit 1
fi

for i in "${ignore_files[@]}"; do
         drupalfiles=(${drupalfiles[@]//*$i*})
done

for dir in "${drupalfiles[@]}";
   do echo "$dir";
done
