FROM centos:centos7
MAINTAINER PanDA team

RUN yum -y update; yum clean all
RUN yum -y install sudo epel-release; yum clean all
RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN yum install -y postgresql13-server pg_cron_13 pg_partman13 postgresql13-contrib; yum clean all
RUN yum -y install supervisor pwgen; yum clean all
# RUN yum -y install postgresql-server postgresql postgresql-contrib supervisor pwgen; yum clean all

RUN mkdir -p /usr/pgsql/
RUN ln -s /usr/pgsql-13/bin /usr/pgsql/bin
# RUN ln -s /var/lib/pgsql /var/lib/postgresql
RUN mkdir -p /var/lib/postgresql/data

RUN mkdir /docker-entrypoint-initdb.d
ADD pandasql /docker-entrypoint-initdb.d/

ENV PG_MAJOR 13
ENV PATH $PATH:/usr/pgsql/bin:/usr/local/bin

ENV PG_VERSION 13.6

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql

ENV PGDATA /var/lib/postgresql/data
# this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"
VOLUME /var/lib/postgresql/data

# COPY docker-entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["docker-entrypoint.sh"]

COPY start_postgres.sh /usr/local/bin/
ENTRYPOINT ["start_postgres.sh"]

STOPSIGNAL SIGINT

EXPOSE 5432
CMD ["postgres"]
