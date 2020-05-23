#!/bin/bash

DEBUG="yes"
#NGINX_ENABLED_DIR="/etc/nginx/sites-enabled" # Use for sanity checks.
SCHEME="https://"
PREFIX="m" # Subdomain DNS prefix required for local CMS processing.
LOADBALANCER="lbint" # Where to point wget. See wait_time wget option.
CHANGESSTRING=".changes" # Identifying string for working files
DOCROOTDIR="/var/www/html"
STAGINGDIR="$DOCROOTDIR/staging"
LIVEDIR="$DOCROOTDIR/live"
WORKINGDIR="$DOCROOTDIR/$CHANGESSTRING" # Processing directory. Make sure nginx has rule for securing dotfiles.
DOMAINSFILE="$WORKINGDIR/domains.lst"
RSYNCSTERSCRIPT="$HOME/rsyncster/main.sh"
DRUPALCACHE="Off" # Off by default. Script will not clear cache. If enabled, know the performance hit on larger sites.
APPSERVERS="cloud1int cloud2int"
APPSERVERSSHORTNAME="cloud"
APPSERVERSMASTER="cloud2int"
LIBDIR="$HOME/rsyncster/lib"
LOGDIR="/var/log/rsyncster"
WEBUSER="kelley"
status="$LOGDIR/datasync-$CHANGESSTRING.status"
exclusions="$LIBDIR/exclusions.lst"
waittime="" # Passed to wget to manage server load during fetch.
stagingservers=(localhost 192.168.0.206)
webservers=(192.168.0.206 192.237.251.89 73.24.185.56)

export DEBUG SCHEME PREFIX LOADBALANCER CHANGESSTRING LIVEDIR DOCROOTDIR STAGINGDIR LIVEDIR WORKINGDIR DOMAINSFILE RSYNCSTERSCRIPT DRUPALCACHE APPSERVERS APPSERVERSSHORTNAME APPSERVERSMASTER LIBDIR LOGDIR WEBUSER status exclusions waittime stagingservers webservers

