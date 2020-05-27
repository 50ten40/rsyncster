#!/bin/bash

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_timestamp.sh

cd $WORKINGDIR

drupal_files_list=($(ssh $APPSERVERSMASTER 'bash $HOME/rsyncster/drupalfiles_get.sh'))

#mapfile -t <$HOME/rsyncster/virt_domains.list

   for d in "${drupal_files_list[@]}"; do
	echo "$(timestamp) - TASK - Setting up end of year refresh for ${d%%/}" >> $status
	mkdir -v ${d%%/} >> $status
	cd ${d%%/}
	touch $PREFIX.${d%%/}
	echo " - TASK - Creating flag $PREFIX.${d%%/}" in $WORKINGDIR/${d%%/} >> $status
	cd $WORKINGDIR
   done
