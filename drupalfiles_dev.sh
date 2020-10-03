#!/bin/bash
# This helper script gets dev and standalone domains list from primary APPSERVER

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh

if [ -d "$DOCROOTDIR/$DRUPAL_MULTISITE_DOMAIN/sites" ] ; then # check if we are on primary appserver
   cd $DOCROOTDIR
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

# remove multisite files from drupalfiles

cd $DOCROOTDIR/$DRUPAL_MULTISITE_DOMAIN/sites
   shopt -s dotglob
   shopt -s nullglob
   multifiles=(*/)

for i in "${multifiles[@]}"; do
         drupalfiles=(${drupalfiles[@]//*$i*})
done

# remove learning domains
for i in "${DRUPAL_LEARN_DOMAINS[@]}"; do
         drupalfiles=(${drupalfiles[@]//*$i*})
done

# remove analytics domains TODO: aggregate arrays
for i in "${DRUPAL_ANALYTICS_DOMAINS[@]}"; do
         drupalfiles=(${drupalfiles[@]//*$i*})
done

for dir in "${drupalfiles[@]}";
   do echo "$dir";
done
