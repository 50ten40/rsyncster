#!/bin/bash

sync() {

        mapfile -t <$DOMAINS_FILE
        #source $RSYNCSTER_SCRIPT "${MAPFILE[@]}"

        for i in "${MAPFILE[@]}"; do

		echo "$(timestamp) - TASK : Sync of $i" started >> $status

                START_TIME=`echo $(($(date +%s%N/1000000000)))`
                
		$RSYNCSTER_SCRIPT $i cron
                
		END_TIME=`echo $(($(date +%s%N/1000000000)))`
                ELAPSED_TIME=$(($END_TIME - $START_TIME))

                echo "$(timestamp) - SUCCESS : Sync of $i completed in $ELAPSED_TIME seconds" >> $status

                for f in $APP_SERVERS; do
                
		        ssh root@$f "rm $WORKING_DIR/m.$i"
                        echo "$TIMESTAMP - TASK : Removing $i from $WORKING_DIR on $f" >> $status
                
		done
        done
}
