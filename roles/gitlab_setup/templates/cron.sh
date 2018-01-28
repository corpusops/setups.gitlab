#!/usr/bin/env bash
gitlab-rake gitlab:backup:create RAILS_ENV=production 2>&1 >/log
ret=$?
if [ "x$ret" != "x0" ];then cat /log;fi
while read oldlog;do rm -f "$oldlog";done < <(\
find "{{gitlab_backups_path}}" \
    -maxdepth 1 -name "*.tar" -type f \
    -printf "%T+ %p\n"\
 | sort -nr\
 | sed '1,{{gitlab_backups_keep}}d'|awk '{print $2}'; )
rm -f /log
exit $ret
# vim:set et sts=4 ts=4 tw=80:
