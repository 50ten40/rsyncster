#!/bin/bash

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_timestamp.sh

cd $WORKINGDIR

if ! [ $APPSERVERSMASTER eq $(hostname -s) ] ; then
	echo "$(timestamp)- TASK - Getting drupal files list on remote machine $APPSERVERSMASTER"
	cmd=(ssh $APPSERVERSMASTER 'bash $HOME/rsyncster/drupalfiles_get.sh')
else
	echo "$(timestamp)- TASK - Getting local drupal files list on local machine $APPSERVERSMASTER"
	cmd=('bash $HOME/rsyncster/drupalfiles_get.sh')
fi

drupal_files_list=$cmd

#mapfile -t <$HOME/rsyncster/virt_domains.list

   for d in "${drupal_files_list[@]}"; do
	echo "$(timestamp) - TASK - Setting up end of year refresh for ${d%%/}"
	mkdir -v ${d%%/}
	cd ${d%%/}
	touch $PREFIX.${d%%/}
	echo " - TASK - Creating flag $PREFIX.${d%%/}" in $WORKINGDIR/${d%%/} 
	cd $WORKINGDIR
   done
