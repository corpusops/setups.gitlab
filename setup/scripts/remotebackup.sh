#!/bin/bash
set -ex
cd "$(dirname $(readlink -f $0))"/..
[ ! -f .env ] && exit 1
source <(grep -v '^#' .env | sed -E 's|^(.+)=(.*)$|: ${\1=\2}; export \1|g')
pwd

if [[ -z ${NO_SYNC-} ]];then
    systemctl stop $COMPOSE_PROJECT_NAME || /bin/true
    $dc stop || true
    scripts/sync.sh
fi

systemctl start $COMPOSE_PROJECT_NAME
while true;do
        content=$(curl -H "X-Forwarded-Proto: https" localhost:{{gitlab_simple_http_port}}/signin  2>&1 || /bin/true)
        if ( echo $content | grep -q 'users/sign_in">redirected' );then
            break
        else
            sleep 1
        fi
done

$dc exec backup /backupswrapper/cronw.sh 
