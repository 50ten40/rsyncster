#!/bin/bash

aggregate_changes() {

        rm /tmp/$CHANGES_STRING.lst

        for i in $APP_SERVERS; do
                echo " - TASK : Getting domains list on $i" >> $status

                ssh root@$i "find $WORKING_DIR/ -maxdepth 1 -printf \"%f\n\"" >> /tmp/$CHANGES_STRING.lst

        done

        if [ ! -d $WORKING_DIR ] ; then
                mkdir $WORKING_DIR
        fi

        sed -i s/^$PREFIX\.//g /tmp/$CHANGES_STRING.lst
        sort /tmp/$CHANGES_STRING.lst -u > $DOMAINS_FILE
        sed -i s/"$CHANGES_STRING\/"/""/g $DOMAINS_FILE
        sed -i /^$/d $DOMAINS_FILE

        for i in $APP_SERVERS; do

                if [ ! -d $WORKING_DIR/$i ] ; then
                        mkdir $WORKING_DIR/$i
                fi
                echo " - TASK : Getting changed file listing on $i" >> $status
                scp root@$i:$WORKING_DIR/* $WORKING_DIR/$i/
        done

        mapfile -t <$DOMAINS_FILE

        for d in "${MAPFILE[@]}"; do


                if [ ! -d $WORKING_DIR/$d ] ; then
                        mkdir $WORKING_DIR/$d
                fi
		
		if [ ! -s $WORKING_DIR/$d/m.$d ] ; then
		
                	find $WORKING_DIR/$APP_SERVERS_SHORTNAME*/ -name $PREFIX.$d -print0 | xargs -0 -I file cat file > /tmp/$CHANGES_STRING.$PREFIX.$d
                	sort /tmp/$CHANGES_STRING.$PREFIX.$d -u > $WORKING_DIR/$d/$PREFIX.$d

		else 

			echo " - TASK : Still processing changes list for $d" >> $status

		fi
        done
}

