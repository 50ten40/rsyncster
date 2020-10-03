#!/bin/bash

LIBPATH="$HOME/rsyncster/lib"
. $LIBPATH/env.sh
. $LIBPATH/function_timestamp.sh

cd $WORKINGDIR

echo "$(timestamp)- TASK - Getting local drupal multisite list on $APPSERVERSMASTER" >> $status

drupal_files_list=$(bash $HOME/rsyncster/drupalfiles_get.sh)

   for d in "${drupal_files_list[@]}"; do
	echo "$(timestamp) - TASK - Setting up end of year refresh for drupal multisite - ${d%%/}" >> $status
	mkdir -v ${d%%/}
	cd ${d%%/}
	touch $PREFIX.${d%%/}
	echo -e " - TASK - Created flag $PREFIX.${d%%/} in $WORKINGDIR/${d%%/}\n" 
	cd $WORKINGDIR
   done

echo "$(timestamp) - TASK - Getting local drupal dev list on $APPSERVERSMASTER" >> $status

drupal_dev_list=$(bash $HOME/rsyncster/drupalfiles_dev.sh)

   for d in "${drupal_dev_list[@]}"; do
        echo "$(timestamp) - TASK - Setting up end of year refresh for drupal devsite - ${d%%/}" >> $status
        mkdir -v ${d%%/}
        cd ${d%%/}
        touch $PREFIX.${d%%/}
        echo -e " - TASK - Created flag $PREFIX.${d%%/} in $WORKINGDIR/${d%%/}\n" 
        cd $WORKINGDIR
   done

if [ $DEBUG="yes" ] ; then
   echo -e "============= end of year debug log =============\n"
   cat $status
fi
