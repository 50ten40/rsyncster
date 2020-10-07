#!/bin/bash

DEBUG="no"
#NGINX_ENABLED_DIR="/etc/nginx/sites-enabled" # Use for sanity checks.
SCHEME="https://"
PREFIX="m" # Subdomain DNS prefix required for local CMS processing.
NPREFIX="static" # Used for nginx auto config
HAPREFIX="" # Haproxy + nginx servers auto config
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
DRUPAL_MULTISITE_DOMAIN="kelleygraham.com"

# drupal development and mixed docroot environment. TODO: cleanup dotglobbing
DRUPAL_WEBHEAD_PATH="sites/default/files" # path to push drupafiles to webheads
DRUPAL_DEV_DOMAINS=(50ten40.com cinematic.tools durastudio.com exif.studio learner.tools tucsonkids.com)
DRUPAL_LEARN_DOMAINS=(lrs.learner.tools learn.taichiboost.com learn.sifuondemand.com moodledata-nfs maker.50ten40.com learn.sifuondemand.com online.learner.tools online.learner.tools-moodle-local stodkphoto.tools learn.unbreakable.center learn.taichiboost.com rumsoakedfist.org dev.rumsoakedfist.org stockphoto.tools)
DRUPAL_ANALYTICS_DOMAINS=(analytics.durastudio.com)

# other variables
LIBDIR="$HOME/rsyncster/lib"
LOGDIR="/var/log/rsyncster"
WEBUSER="kelley"
status="$LOGDIR/datasync-$CHANGESSTRING.status"
exclusions="$LIBDIR/exclusions.lst"
waittime="" # Passed to wget to manage server load during fetch.
stagingservers=(localhost 192.168.0.206)
webservers=(192.168.0.206 192.168.0.147 192.237.251.89 69.137.188.72)

# used to filter dotglob arrays TODO: cleanup dotglobbibng throughout
ignore_files=(.changes all default permatecture.pro faf.photos braingurus.com signup.fafchat.com signup.faf.chat signup.faf.photos rodpweiss.com signup.faf.social signup.mastery.chat) # used for drupalfiles_get.sh

export DRUPAL_LEARN_DOMAINS DRUPAL_ANALYTICS_DOMAINS ignore_files DRUPAL_WEBHEAD_PATH DRUPAL_MULTISITE_DOMAIN DRUPAL_DEV_DOMAINS DEBUG SCHEME PREFIX NPREFIX HAPREFIX LOADBALANCER CHANGESSTRING LIVEDIR DOCROOTDIR STAGINGDIR LIVEDIR WORKINGDIR DOMAINSFILE RSYNCSTERSCRIPT DRUPALCACHE APPSERVERS APPSERVERSSHORTNAME APPSERVERSMASTER LIBDIR LOGDIR WEBUSER status exclusions waittime stagingservers webservers
