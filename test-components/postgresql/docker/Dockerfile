FROM postgres:13.6

RUN apt update
RUN apt-get install -y postgresql-13-cron postgresql-13-partman

RUN echo "shared_preload_libraries = 'pg_cron, pg_partman_bgw'" >> /usr/share/postgresql/postgresql.conf.sample
RUN echo "cron.database_name = 'postgres'" >> /usr/share/postgresql/postgresql.conf.sample
RUN echo "pg_partman_bgw.dbname = 'panda_db'" >> /usr/share/postgresql/postgresql.conf.sample
