#!/usr/bin/env bash
set -ex
cd "$(dirname $(readlink -f $0))"/..
[ ! -f .env ] && exit 1
source <(grep -v '^#' .env | sed -E 's|^(.+)=(.*)$|: ${\1=\2}; export \1|g')


pwd
systemctl stop compose-gitlab || /bin/true
for i in data/;do
    rsync -Aazv $OLD_HOST:${OLD_PATH}/$i/ $i/ --exclude=prometheus/data --exclude=/backups/
done
$dc up -d --force-recreate
