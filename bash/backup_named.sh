#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
DIR_PATH=/mnt/backup/ns7_$TIMESTAMP
echo " backup started to $DIR_PATH"

mkdir $DIR_PATH
cp /etc/named.conf $DIR_PATH
cp -R /var/named  $DIR_PATH
tar czf /mnt/backup/ns7_$TIMESTAMP.tar.gz $DIR_PATH --remove-files $DIR_PATH
