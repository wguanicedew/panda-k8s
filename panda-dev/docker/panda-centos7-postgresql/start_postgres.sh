#!/bin/bash

DB_NAME=${POSTGRES_DB:-}
DB_USER=${POSTGRES_USER:-}
DB_PASS=${POSTGRES_PASSWORD:-}
DB_SCHEMA=${POSTGRES_SCHEMA:-}
PANDA_DB=${PANDA_DB:-}
PANDA_USER=${PANDA_USER:-}
PANDA_PASS=${PANDA_PASSWORD:-}
PANDA_SCHEMA=${PANDA_SCHEMA:-}

PG_CONFDIR="/var/lib/postgresql/data"
PGDATA="/var/lib/postgresql/data"

PGVERSION=13.6
PGENGINE=/usr/pgsql/bin
PGPORT="5432"

# Log file for initdb
PGLOG=/var/lib/pgsql/initdb.log

# Log file for pg_upgrade
PGUPLOG=/var/lib/pgsql/pgupgrade.log

export PGDATA
export PGPORT

# For SELinux we need to use 'runuser' not 'su'
if [ -x /sbin/runuser ]; then
    SU=runuser
else
    SU=su
fi

if [ ! -n "${DB_USER}" ]; then
    DB_USER=admin
fi

if [ ! -n "${DB_PASS}" ]; then
    DB_PASS=password
fi

if [ ! -n "${DB_SCHEMA}" ]; then
    DB_SCHEMA=public
fi

if [ ! -n "${PANDA_DB}" ]; then
    PANDA_DB=panda_db
fi

if [ ! -n "${PANDA_USER}" ]; then
    PANDA_USER=panda
fi

if [ ! -n "${PANDA_PASS}" ]; then
    PANDA_PASS=password
fi

if [ ! -n "${PANDA_SCHEMA}" ]; then
    PANDA_SCHEMA=doma_panda
fi

__pg_setup_db() {
    if [ ! -e "$PGDATA" ]; then
        mkdir "$PGDATA" || return 1
        chown postgres:postgres "$PGDATA"
        chmod go-rwx "$PGDATA"
    fi

    chown postgres:postgres "$PGDATA"
    chmod go-rwx "$PGDATA"

    # Initialize the database
    echo "initializing db"
    # $SU -l postgres -c "$PGENGINE/initdb --pgdata='$PGDATA' --username='$DB_USER' --pwfile=<(echo '$DB_PASS') --auth='md5'"
    $SU -l postgres -c "$PGENGINE/initdb --pgdata='$PGDATA' --username='$DB_USER' --pwfile=<(echo '$DB_PASS')"
    echo "initialized db"

    if [ -n "${DB_NAME}" ]; then
        # $SU -l postgres -c "$PGENGINE/psql --user='$DB_USER' --prompt='$DB_PASS' -c 'create database ${DB_NAME}; GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};'"
        echo $SU -l postgres -c "/usr/pgsql/bin/pg_ctl -o \"-c listen_addresses='' -p '${PGPORT:-5432}'\" -D $PGDATA start"
        $SU -l postgres -c "/usr/pgsql/bin/pg_ctl -o \"-c listen_addresses='' -p '${PGPORT:-5432}'\" -D $PGDATA start"
        
        # echo $SU -l postgres -c "$PGENGINE/psql --username='$DB_USER' --dbname=postgres --no-password -c '\\set AUTOCOMMIT on; create database ${DB_NAME}; GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};'"
        echo $SU -l postgres -c "$PGENGINE/psql --username='$DB_USER' --dbname=postgres --no-password -c 'create database ${DB_NAME}'"
        $SU -l postgres -c "$PGENGINE/psql --username='$DB_USER' --dbname=postgres --no-password -c 'create database ${DB_NAME}'"

        echo $SU -l postgres -c "$PGENGINE/psql --username='$DB_USER' --dbname=postgres --no-password -c 'GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER}'"
        $SU -l postgres -c "$PGENGINE/psql --username='$DB_USER' --dbname=postgres --no-password -c 'GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER}'"

        echo $SU -l postgres -c "/usr/pgsql/bin/pg_ctl -D $PGDATA stop"
        $SU -l postgres -c "/usr/pgsql/bin/pg_ctl -D $PGDATA stop"
    fi

    if [ -f "$PGDATA/PG_VERSION" ]; then
        return 0
    fi
    return 1
}


__pg_setup_pg_conf() {
    if [ -s "$PGDATA/postgresql.conf" ]; then
        echo "password_encryption = md5" >> $PGDATA/postgresql.conf
        echo "listen_addresses = '*'" >> $PGDATA/postgresql.conf
        echo "shared_preload_libraries = 'pg_cron, pg_partman_bgw'" >> $PGDATA/postgresql.conf
        echo "cron.database_name = 'postgres'" >> $PGDATA/postgresql.conf
        echo "pg_partman_bgw.dbname = 'panda_db'" >> $PGDATA/postgresql.conf
    fi

    if [ -s "$PGDATA/pg_hba.conf" ]; then
        echo "local   all  panda       trust" >> $PGDATA/pg_hba.conf
        echo "host    all  panda       localhost     trust" >> $PGDATA/pg_hba.conf
        echo "local   all  postgres    trust" >> $PGDATA/pg_hba.conf
        echo "host    all  postgres    localhost     trust" >> $PGDATA/pg_hba.conf
        echo "host    all  all         0.0.0.0/0     md5" >> $PGDATA/pg_hba.conf
        echo "host    all  all        ::0/0          md5" >> $PGDATA/pg_hba.conf
    fi
}

__pg_setup_panda_db() {
    echo $SU -l postgres -c "/usr/pgsql/bin/pg_ctl -o \"-c listen_addresses='' -p '${PGPORT:-5432}'\" -D $PGDATA start"
    $SU -l postgres -c "/usr/pgsql/bin/pg_ctl -o \"-c listen_addresses='' -p '${PGPORT:-5432}'\" -D $PGDATA start"

    psql --username admin --dbname postgres --no-password << EOF
        CREATE DATABASE panda_db;
        CREATE USER panda PASSWORD '$PANDA_PASS';
        ALTER ROLE panda SET search_path = doma_panda,public;
        CREATE EXTENSION pg_cron;
        GRANT USAGE ON SCHEMA cron TO panda;
        \c panda_db;
        CREATE SCHEMA partman;
        CREATE EXTENSION pg_partman SCHEMA partman;
EOF

    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDA_SEQUENCE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDA_TABLE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDA_SEQUENCE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDAMETA_SEQUENCE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDAMETA_TABLE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDAARCH_SEQUENCE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDAARCH_TABLE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_DEFT_TABLE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDABIGMON_SEQUENCE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDABIGMON_TYPE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDABIGMON_TABLE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDABIGMON_VIEW.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDABIGMON_TRIGGER.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDABIGMON_PROCEDURE.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PANDABIGMON_FUNCTION.sql
    psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PARTITION.sql

    # psql --username admin --dbname panda_db --no-password  -f /docker-entrypoint-initdb.d/pg_PARTITION.sql

    echo $SU -l postgres -c "/usr/pgsql/bin/pg_ctl -D $PGDATA stop"
    $SU -l postgres -c "/usr/pgsql/bin/pg_ctl -D $PGDATA stop"
}

__start_db() {
    echo "list $PGDATA"
    ls -l $PGDATA

    declare -g DATABASE_ALREADY_EXISTS
    # look specifically for PG_VERSION, as it is expected in the DB dir
    if [ -s "$PGDATA/PG_VERSION" ]; then
        DATABASE_ALREADY_EXISTS='true'
        echo "Database already exists: $DATABASE_ALREADY_EXISTS"
    fi

    if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
        echo "Database does not exists,DATABASE_ALREADY_EXISTS: $DATABASE_ALREADY_EXISTS"
        echo "setup db"
        __pg_setup_db
        __pg_setup_pg_conf
        __pg_setup_panda_db
    fi

    # $SU -l postgres -c "/usr/pgsql/bin/postgres -D $PGDATA"
    $SU -l postgres -c "/usr/pgsql/bin/pg_ctl -D $PGDATA start"
    trap : TERM INT; sleep infinity & wait
}


__main() {
   if [ "$1" = 'postgres' ]; then
        __start_db
   else
       exec "$@"
   fi
}


# Call all functions
__main "$@"

