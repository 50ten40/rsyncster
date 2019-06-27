#!/bin/bash

ignore_files=(all default)

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


