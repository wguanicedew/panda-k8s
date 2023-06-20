#!/bin/bash

filename=${MARIADB_DATABASE}_${HOSTNAME}_$(date "+%Y.%m.%d-%H.%M.%S")
# dump the db
mysqldump -u root -p${MARIADB_ROOT_PASSWORD} --databases ${MARIADB_DATABASE} > /tmp/${filename}

cp /opt/conf/id_rsa /tmp/backup_id_rsa
chmod 600 /tmp/backup_id_rsa

# scp
# scp -q -i /tmp/backup_id_rsa  /tmp/${filename}  lsstsvc1@sdfrome001.sdf.slac.stanford.edu:/sdf/data/rubin/panda_jobs/panda_backup/
# scp -q -i /tmp/backup_id_rsa  /tmp/${filename} ${BACKUP_PATH}
scp -q -o "ConnectTimeout 10"  -o "StrictHostKeyChecking no"  -o "UserKnownHostsFile /dev/null" -i /tmp/backup_id_rsa  /tmp/${filename} ${BACKUP_PATH}

rm -fr /tmp/${filename} /tmp/backup_id_rsa
