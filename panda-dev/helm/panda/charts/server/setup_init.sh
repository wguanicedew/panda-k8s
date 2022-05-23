#!/bin/bash

if [ -f /opt/panda/etc/cert/hostcert.pem ]; then
    echo "host certificate is already created." 
else
    mkdir -p /opt/panda/etc/cert
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -subj "/C=US/DC=IDDS/OU=computers/CN=$(hostname -f)" \
        -keyout /opt/panda/etc/cert/hostkey.pem \
        -out /opt/panda/etc/cert/hostcert.pem
fi

