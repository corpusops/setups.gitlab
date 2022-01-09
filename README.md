# docker based gitlab fullstack deployment using ansible
See playbooks, set your variables and enjoy


## gitlab 15 migration notes
- pull both 15.x images

    ```sh
    for i in gitlab/gitlab-ce:15.0.4-ce.0  gitlab/gitlab-ce:15.1.1-ce.0;do docker pull $i;done
    ```
- upgade to `15.0.4-ce.0` (in docker-compose.yml) (4m)
- upgrade to latest bundled postgresql (5m)

    ```sh
    docker-compose exec web gitlab-ctl pg-upgrade -w
    ```
- upgrade to latest 15 on https://hub.docker.com/r/gitlab/gitlab-ce/tags
- set 15.1 in docker-compose.yml & restart
