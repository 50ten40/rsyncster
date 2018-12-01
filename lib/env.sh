#!/bin/sh

#NGINX_ENABLED_DIR="/etc/nginx/sites-enabled" # Todo: Use for sanity checks.
PREFIX="m" # Subdomain name for CMS.
CHANGES_STRING=".changes" # Identifying string used in various contexts. 
DOCROOT_DIR="/var/www/html"
MANAGE_DIR="/home/kelley/manage"
WORKING_DIR="$DOCROOT_DIR/$CHANGES_STRING"
PAGES_FILE="pages.lst"
DOMAINS_FILE="$DOCROOT_DIR/$CHANGES_STRING/domains.lst"
RSYNCSTER_SCRIPT="$MANAGE_DIR/rsyncster/main.sh"
APP_SERVERS="cloud1int cloud2int"
APP_SERVERS_SHORTNAME="cloud"
APP_SERVERS_MASTER="cloud2int"
status="$MANAGE_DIR/datasync-$CHANGES_STRING.status"
exclusions="$LIB_DIR/exclusions.lst
