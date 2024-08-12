#!/usr/bin/env bash
set -ex
cd "$(dirname $(readlink -f $0))"/..
[ ! -f .env ] && exit 1
source <(grep -v '^#' .env | sed -E 's|^(.+)=(.*)$|: ${\1=\2}; export \1|g')

ropts="-Aazv --delete --exclude=prometheus/data --exclude=/backups/ --exclude=postgresql/data.*"

pwd
if [[ -z "$SKIP_SYNC_STOP-1}" ]];then
    systemctl stop compose-gitlab || /bin/true
    $dc stop -t0
fi

sync_() {
    local i="$1"
    rsync $ropts  -e "ssh -o Port=$SYNC_SSH_PORT" $SYNC_HOST:${SYNC_PATH}/$i $i
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

if [[ -z "${SKIP_SYNC_LOCAL_DATA-}" ]];then
    [[ -z "${SKIP_SYNC_DATA-}" ]]  && sync_ data/
    [[ -z "${SKIP_SYNC_LOG-}" ]]   && sync_ log/
    [[ -z "${SKIP_SYNC_PAGES-}" ]] && sync_ pages/
    [[ -z "${SKIP_SYNC_SHARE-}" ]] && sync_ share/
fi

if [[ -z "${SKIP_SYNC_S3_DATA-}" ]];then
    $dc run --rm --entrypoint bash scripts -exc "for i in $GITLAB_S3_BUCKETS;do rclone sync -vvvv  ovh:${GITLAB_S3_PROD_PREFIX}-\${i} ovh:${GITLAB_S3_STAGING_PREFIX}-\${i};done"
fi

$dc up -d --force-recreate web backup

waitup

# rename gitlab instance to staging
$dc exec web sh -c 'echo "update appearances set title='"'$GITLAB_TITLE'"' where id=1"|gitlab-psql'

# deactivate all automatic CICD pipelines
$dc exec web bash -ec "gitlab-rails runner 'Ci::PipelineSchedule.all.each do |p| p.deactivate! end'"
# vim:set et sts=5 ts=4 tw=0:
