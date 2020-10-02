#!/bin/bash

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_timestamp.sh

cd $WORKINGDIR

echo "$(timestamp)- TASK - Getting local drupal files list on $APPSERVERSMASTER"

drupal_files_list=$(bash $HOME/rsyncster/drupalfiles_get.sh)

   for d in "${drupal_files_list[@]}"; do
	echo "$(timestamp) - TASK - Setting up end of year refresh for ${d%%/}"
	mkdir -v ${d%%/}
	cd ${d%%/}
	touch $PREFIX.${d%%/}
	echo " - TASK - Creating flag $PREFIX.${d%%/}" in $WORKINGDIR/${d%%/} 
	cd $WORKINGDIR
   done
