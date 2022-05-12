#!/bin/sh

BIGMON_SERVICE=$1


if [ "${BIGMON_SERVICE}" == "all" ]; then
  echo "starting bigmon http service"
  /usr/sbin/httpd
else
  exec "$@"
fi

trap : TERM INT; sleep infinity & wait
