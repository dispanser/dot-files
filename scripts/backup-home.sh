#!/usr/bin/env bash

cd /home/data/backup
ENV=$1
echo `date` backup $ENV started >> backup.log
source /home/pi/configs/backup/$ENV.env
FILE=/tmp/restic.run.log
set -e
export PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/usr/bin:~/.nix-profile/bin
if restic -r $TARGET backup /home/pi --exclude-file=/home/data/backup/backup_exclude --exclude-caches 2> $FILE; then
  echo `date` backup $ENV finished >> backup.log
else
  cat $FILE >> backup.log
  echo `date` backup $ENV FAILED >> backup.log
fi

touch successful
