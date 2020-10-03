#!/bin/bash
# This helper script gets multisite domains list from primary APPSERVER

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh

if [ -d "$DOCROOTDIR/$DRUPAL_MULTISITE_DOMAIN/sites" ] ; then # check if we are on primary appserver
   cd $DOCROOTDIR/$DRUPAL_MULTISITE_DOMAIN/sites
   shopt -s dotglob
   shopt -s nullglob
   drupalfiles=(*/)
else
   echo " - FAILURE - Please run on primary appserver -- $APPSERVERSMASTER --" >> $status
   if [[ $DEBUG="yes" ]] ; then
      cat $status | grep FAILURE
   fi
   exit 1
fi

for i in "${ignore_files[@]}"; do
         drupalfiles=(${drupalfiles[@]//*$i*})
done

for dir in "${drupalfiles[@]}";
   do echo "$dir";
done
