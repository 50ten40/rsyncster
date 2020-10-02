#!/bin/bash
# This helper script get drupalfiles path from primary APPSERVER

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_timestamp.sh

if ! [ -d "/var/www/html/kelleygraham.com/sites" ] ; then # check if we are on an appserver
   #echo " - PASSED - We are running on an appserver" >> $status
#else
   echo " - ERROR - Please run on primary APPSERVER" # >> $status
   exit 1
fi

if [ $1 = $DRUPAL_MULTISITE_DOMAIN ] ; then
   #echo " - TASK - $1 is Drupal Primary Multisite" >> $status 
   drupalfiles_path="sites/default/files"
elif [[ " ${DRUPAL_DEV_DOMAINS[@]} " =~ " $1 " ]]; then
   #echo " - TASK - $1 is Drupal Development or Standalone site" >> $status
   drupalfiles_path="sites/default/files"
else
   #echo " - TASK - $1 is Drupal subsite under $DRUPAL_MULTISITE_DOMAIN" >> $status
   drupalfiles_path="sites/default/files/$1"
fi

#echo " - TASK - Found drupalfiles path at $drupalfiles_path" >> $status
echo "$drupalfiles_path";
