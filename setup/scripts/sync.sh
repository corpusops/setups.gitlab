#!/usr/bin/env bash
set -ex
cd "$(dirname $(readlink -f $0))"/..
[ ! -f .env ] && exit 1
source <(grep -v '^#' .env | sed -E 's|^(.+)=(.*)$|: ${\1=\2}; export \1|g')

ropts="-Aazv --delete --exclude=prometheus/data --exclude=/backups/ --exclude=postgresql/data.*"

pwd
[[ -z "$SKIP_SYNC_STOP-1}" ]] && systemctl stop compose-gitlab || /bin/true
sync_() {
    local i="$1"
    rsync $ropts  -e "ssh -o Port=$SYNC_SSH_PORT" $SYNC_HOST:${SYNC_PATH}/$i nobackup/$i
    rsync $ropts  nobackup/$i $i
}
waitup() {
    while true;do
            content=$(curl -H "X-Forwarded-Proto: https" localhost:80/signin  2>&1 || /bin/true)
            if ( echo $content | grep -q 'users/sign_in">redirected' );then
                break
            else
                sleep 1
            fi
    done
}
[[ -z "${SKIP_SYNC_DATA-}" ]] && sync_ data/
[[ -z "${SKIP_SYNC_LOG-}" ]] && sync_ log/
$dc up -d --force-recreate
{% if gitlab_change_title %}
waitup
$dc exec web sh -c 'echo "update appearances set title='"'$GITLAB_TITLE'"' where id=1"|gitlab-psql'
{% endif %}
