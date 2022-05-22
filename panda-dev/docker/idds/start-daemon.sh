#!/bin/sh

IDDS_SERVICE=$1

source /etc/profile.d/conda.sh
conda activate /opt/idds;

export IDDS_HOME=/opt/idds

if [ -f /etc/grid-security/hostkey.pem ]; then
    echo "host certificate is already created."
elif [ -f /opt/idds/configmap/hostkey.pem ]; then
    echo "mount /opt/idds/configmap/hostkey.pem to /etc/grid-security/hostkey.pem"
    ln -fs /opt/idds/configmap/hostkey.pem /etc/grid-security/hostkey.pem
    ln -fs /opt/idds/configmap/hostcert.pem /etc/grid-security/hostcert.pem
fi

if [ -f /opt/idds/config/idds/idds.cfg ]; then
    echo "idds.cfg already mounted."
else
    echo "idds.cfg not found. will generate one."
    python3 /opt/idds/tools/env/merge_idds_configs.py \
        -s /opt/idds/config_default/idds.cfg $IDDS_OVERRIDE_IDDS_CONFIGS \
        --use-env \
        --prefix IDDS_CFG_IDDS \
        -d /opt/idds/config/idds/idds.cfg
    python3 /opt/idds/tools/env/merge_configmap.py \
        -s /opt/idds/configmap/idds_configmap.json \
        -d /opt/idds/config/idds/idds.cfg
fi

if [ -f /opt/idds/config/idds/auth.cfg ]; then
    echo "auth.cfg already mounted."
else
    echo "auth.cfg not found. will generate one."
    python3 /opt/idds/tools/env/merge_idds_configs.py \
        -s /opt/idds/config_default/auth.cfg $IDDS_OVERRIDE_AUTH_CONFIGS \
        --use-env \
        --prefix IDDS_CFG_AUTH \
        -d /opt/idds/config/idds/auth.cfg
    python3 /opt/idds/tools/env/merge_configmap.py \
        -s /opt/idds/configmap/idds_configmap.json \
        -d /opt/idds/config/idds/auth.cfg
fi

if [ -f /opt/idds/config/idds/gacl ]; then
    echo "gacl already mounted."
else
    echo "gacl not found. will generate one."
    ln -s /opt/idds/config_default/gacl /opt/idds/config/idds/gacl
fi

if [ -f /opt/idds/config/panda.cfg ]; then
    echo "panda.cfg already mounted."
else
    echo "panda.cfg not found. will generate one."
    python3 /opt/idds/tools/env/merge_idds_configs.py \
        -s /opt/idds/config_default/panda.cfg $IDDS_OVERRIDE_PANDA_CONFIGS \
        --use-env \
        --prefix IDDS_CFG_PANDA \
        -d /opt/idds/config/panda.cfg
    python3 /opt/idds/tools/env/merge_configmap.py \
        -s /opt/idds/configmap/idds_configmap.json \
        -d /opt/idds/config/panda.cfg
fi

if [ -f /opt/idds/config/rucio.cfg ]; then
    echo "rucio.cfg already mounted."
else 
    echo "rucio.cfg not found. will generate one."
    python3 /opt/idds/tools/env/merge_idds_configs.py \
        -s /opt/idds/config_default/rucio.cfg $IDDS_OVERRIDE_RUCIO_CONFIGS \
        --use-env \
        --prefix IDDS_CFG_RUCIO \
        -d /opt/idds/config/rucio.cfg
    python3 /opt/idds/tools/env/merge_configmap.py \
        -s /opt/idds/configmap/idds_configmap.json \
        -d /opt/idds/config/rucio.cfg
fi

if [ -f /opt/idds/config/idds/httpd-idds-443-py39-cc7.conf ]; then
    echo "httpd conf already mounted."
else
    echo "httpd conf not found. will use the default one."
    sed -i "s/WSGISocketPrefix\ \/var\/log\/idds\/wsgisocks\/wsgi/WSGISocketPrefix\ \/var\/idds\/wsgisocks\/wsgi/g" /opt/idds/config_default/httpd-idds-443-py39-cc7.conf 
    cp /opt/idds/config_default/httpd-idds-443-py39-cc7.conf /opt/idds/config/idds/httpd-idds-443-py39-cc7.conf
fi

if [ -f /opt/idds/config/idds/supervisord_idds.ini ]; then
    echo "supervisord conf already mounted."
else
    echo "supervisord conf not found. will use the default one."
    cp /opt/idds/config_default/supervisord_idds.ini /opt/idds/config/idds/supervisord_idds.ini
fi

if [ -f /etc/grid-security/hostkey.pem ]; then
    echo "Host certificate already mounted."
else
    echo "Host certificate not found. will generate a self-signed one."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -subj "/C=US/DC=IDDS/OU=computers/CN=$(hostname -f)" \
        -keyout /opt/idds/config/hostkey.pem \
        -out /opt/idds/config/hostcert.pem
    ln -fs /opt/idds/config/hostcert.pem /etc/grid-security/hostcert.pem
    ln -fs /opt/idds/config/hostkey.pem /etc/grid-security/hostkey.pem
fi

mkdir -p /opt/idds/config/.panda/

if [ ! -z "$IDDS_PRINT_CFG" ]; then
    echo "=================== /opt/idds/etc/idds.cfg ============================"
    cat /opt/idds/etc/idds.cfg
    echo ""
    echo "=================== /opt/idds/etc/idds/auth/auth.cfg ============================"
    cat /opt/idds/etc/idds/auth/auth.cfg
    echo ""
    echo "=================== /opt/idds/etc/idds/rest/gacl ============================"
    cat /opt/idds/etc/idds/rest/gacl
    echo ""
    echo "=================== /etc/httpd/conf.d/httpd-idds-443-py39-cc7.conf ============================"
    cat /etc/httpd/conf.d/httpd-idds-443-py39-cc7.conf
    echo ""
    echo "=================== /opt/idds/config/idds/supervisord_idds.ini ============================"
    cat /opt/idds/config/idds/supervisord_idds.ini
    echo ""
    echo "=================== /opt/idds/etc/panda/panda.cfg ============================"
    cat /opt/idds/etc/panda/panda.cfg
    echo ""
    echo "=================== /opt/idds/etc/rucio.cfg ============================"
    cat /opt/idds/etc/rucio.cfg
    echo ""
fi

sed -i 's/Listen\ 443/#\ Listen\ 443/g' /etc/httpd/conf.d/ssl.conf
# create database if not exists
python /opt/idds/tools/env/create_database.py
python /opt/idds/tools/env/config_monitor.py -s ${IDDS_HOME}/monitor/data/conf.js.template -d ${IDDS_HOME}/monitor/data/conf.js  --host ${IDDS_SERVER}
ln -s /opt/idds/configmap/idds2panda_token /opt/idds/config/.token

if [ "${IDDS_SERVICE}" == "rest" ]; then
  echo "starting iDDS ${IDDS_SERVICE} service"
  # systemctl restart httpd.service
  # systemctl enable httpd.service
  # systemctl status httpd.service
  /usr/sbin/httpd
elif [ "${IDDS_SERVICE}" == "daemon" ]; then
  echo "starting iDDS ${IDDS_SERVICE} service"
  # systemctl enable supervisord
  # systemctl start supervisord
  # systemctl status supervisord
  /usr/bin/supervisord -c /etc/supervisord.conf
elif [ "${IDDS_SERVICE}" == "all" ]; then
  echo "starting iDDS rest service"
  /usr/sbin/httpd

  echo "starting iDDS daemon service"
  /usr/bin/supervisord -c /etc/supervisord.conf
else
  exec "$@"
fi

trap : TERM INT; sleep infinity & wait
