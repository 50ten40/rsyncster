#!/bin/bash

LIB_PATH="$HOME/rsyncster/lib"
. $LIB_PATH/env.sh

cd $WORKING_DIR

#cd $MANAGE_DIR/rsyncster/testing

mapfile -t <$MANAGE_DIR/virt_domains.list

   for d in "${MAPFILE[@]}"; do

	mkdir $d
	touch $d/m.$d
   done
