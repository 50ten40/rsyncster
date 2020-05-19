#!/bin/sh

#NGINX_ENABLED_DIR="/etc/nginx/sites-enabled" # Use for sanity checks.
PREFIX="m" # Subdomain DNS prefix for CMS.
LOAD_BALANCER="lbint" # Where to point wget. See wait_time wget option.
CHANGES_STRING=".changes" # Identifying string used in various contexts. Dotfile.
DOCROOT_DIR="/var/www/html"
WORKING_DIR="$DOCROOT_DIR/$CHANGES_STRING" # Processing directory. Make sure nginx has rule for securing dotfiles.
DOMAINS_FILE="$WORKING_DIR/domains.lst"
RSYNCSTER_SCRIPT="$HOME/rsyncster/main.sh"
DRUPAL_CACHE="Off" # Off by default. Script will not clear cache. If enabled, know the performance hit on larger sites.
APP_SERVERS="cloud1int cloud2int"
APP_SERVERS_SHORTNAME="cloud"
APP_SERVERS_MASTER="cloud2int"
LIB_DIR="$HOME/rsyncster/lib"
LOG_DIR="/var/log/rsyncster"
status="$LOG_DIR/datasync-$CHANGES_STRING.status"
exclusions="$LIB_DIR/exclusions.lst"
wait_time="" # Passed to wget to manage server load during fetch.
