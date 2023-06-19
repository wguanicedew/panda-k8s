#!/bin/bash

RUN crontab -l | { cat; echo "0 * * * * bash /usr/local/bin/backup_mysql_cron.sh"; } | crontab -
cron -f &
docker-entrypoint.sh "$@"
