#!/bin/sh
sudo ./rsyncster-wget_static_drupal.pl $1 && sudo ./rsyncster-publish.sh $1 && sudo ./rsyncster-rsync_webheads.sh $1
