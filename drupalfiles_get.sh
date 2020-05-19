#!/bin/bash

ignore_files=(all default kelleygraham.com permatecture.pro faf.photos braingurus.com signup.fafchat.com signup.faf.chat signup.faf.photos rodpweiss.com signup.faf.social signup.mastery.chat)

cd /var/www/html/kelleygraham.com/sites
shopt -s dotglob 
shopt -s nullglob
drupalfiles=(*/)

for i in "${ignore_files[@]}"; do
         drupalfiles=(${drupalfiles[@]//*$i*})
done

for dir in "${drupalfiles[@]}";
   do echo "$dir";
done
