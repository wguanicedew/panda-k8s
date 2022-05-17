#!/bin/sh

BIGMON_SERVICE=$1

ln -s /data/idds/configmap/config.py /data/idds/core/settings/config.py
ln -s /data/idds/configmap/local.py /data/idds/core/settings/local.py

if [ -f /etc/grid-security/hostkey.pem ]; then
    echo "host certificate is already created."
elif [ -f /opt/panda/etc/cert/hostkey.pem ]; then
    echo "mount /opt/panda/etc/cert/hostkey.pem to /etc/grid-security/hostkey.pem"
    ln -fs /opt/panda/etc/cert/hostkey.pem /etc/grid-security/hostkey.pem
    ln -fs /opt/panda/etc/cert/hostcert.pem /etc/grid-security/hostcert.pem
else
    echo "Host certificate not found. will generate a self-signed one."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -subj "/C=US/DC=IDDS/OU=computers/CN=$(hostname -f)" \
        -keyout /data/idds/config/hostkey.pem \
        -out /data/idds/config/hostcert.pem
    ln -fs /opt/idds/config/hostcert.pem /etc/grid-security/hostcert.pem
    ln -fs /opt/idds/config/hostkey.pem /etc/grid-security/hostkey.pem
fi

if [ "${BIGMON_SERVICE}" == "all" ]; then
  echo "starting bigmon http service"
  /usr/sbin/httpd
else
  exec "$@"
fi

trap : TERM INT; sleep infinity & wait
