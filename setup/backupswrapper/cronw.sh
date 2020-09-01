#!/usr/bin/env bash
GITLAB_CONTAINER="${GITLAB_CONTAINER:-{{gitlab_compose_project}}_web_1}"
cd $(dirname $0)
set -eu
fic=$(mktemp)
rm -f $fic
cat cron.sh|docker exec -i "$GITLAB_CONTAINER" \
   sh -c "tee \"$fic\" 2>&1 >/dev/null\
   && chmod +x \"$fic\" \
   && \"$fic\" \
   && rm -f \"$fic\""
# vim:set et sts=4 ts=4 tw=80:
