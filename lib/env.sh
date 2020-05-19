#!/bin/sh

#NGINX_ENABLED_DIR="/etc/nginx/sites-enabled" # Use for sanity checks.
PREFIX="m" # Subdomain DNS prefix for CMS.
LOAD_BALANCER="lbint" # Where to point wget. See wait_time wget option.
CHANGES_STRING=".changes" # Identifying string used in various contexts. Dotfile.
MANAGE_STRING="" # Identifying string for management directory. Optional, leave blank if you cloned into your home directory.
DOCROOT_DIR="/var/www/html"
MANAGE_DIR="$HOME/$MANAGE_STRING" # Your management directory location.
WORKING_DIR="$DOCROOT_DIR/$CHANGES_STRING" # Processing directory. Make sure nginx has rule for securing dotfiles.
DOMAINS_FILE="$DOCROOT_DIR/$CHANGES_STRING/domains.lst"
RSYNCSTER_SCRIPT="$MANAGE_DIR/rsyncster/main.sh"
DRUPAL_CACHE="Off" # Off by default. Script will not clear cache. If enabled, know the performance hit on larger sites.
APP_SERVERS="cloud1int cloud2int"
APP_SERVERS_SHORTNAME="cloud"
APP_SERVERS_MASTER="cloud2int"
LIB_DIR="$MANAGE_DIR/rsyncster/lib"
LOG_DIR="/var/log/rsyncster"
status="$LOG_DIR/datasync-$CHANGES_STRING.status"
exclusions="$LIB_DIR/exclusions.lst"
wait_time="" # Passed to wget to manage server load during fetch.
