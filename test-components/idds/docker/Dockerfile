#!/usr/bin/env python
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0OA
#
# Authors:
# - Wen Guan, <wen.guan@cern.ch>, 2022


FROM docker.io/centos:7

ARG TAG

WORKDIR /tmp

RUN yum install -y epel-release.noarch && \
     yum clean all && \
     rm -rf /var/cache/yum
RUN yum upgrade -y && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN yum install -y httpd.x86_64 conda gridsite mod_ssl.x86_64 httpd-devel.x86_64 gcc.x86_64 supervisor.noarch fetch-crl.noarch lcg-CA postgresql postgresql-contrib postgresql-static postgresql-libs postgresql-devel && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN curl http://repository.egi.eu/sw/production/cas/1/current/repo-files/EGI-trustanchors.repo -o /etc/yum.repos.d/EGI-trustanchors.repo
RUN yum install -y fetch-crl.noarch lcg-CA ca-policy-egi-core && \
    yum clean all && \
    rm -rf /var/cache/yum

# setup env
RUN adduser atlpan
RUN groupadd zp
RUN usermod -a -G zp atlpan

RUN mkdir /opt/idds
RUN mkdir /var/log/idds
RUN mkdir /var/log/idds/wsgisocks/
RUN mkdir /tmp/idds
RUN mkdir /tmp/idds/wsgisocks
RUN chown atlpan -R /opt/idds
# RUN chown atlpan -R /opt/idds_source
RUN chown atlpan /var/log/idds
RUN chown apache -R /tmp/idds/wsgisocks/
RUN chown apache -R /var/log/idds/wsgisocks/

# setup conda virtual env
ADD requirements.yaml /opt/idds/
# ADD start-daemon.sh /opt/idds/
RUN conda env create --prefix=/opt/idds -f /opt/idds/requirements.yaml
RUN source /etc/profile.d/conda.sh; conda activate /opt/idds
# RUN conda activate /opt/idds

# Make RUN commands use the new environment:
# SHELL ["conda", "run", "-p", "/opt/idds", "/bin/bash", "-c"]

# install required packages
RUN source /etc/profile.d/conda.sh; conda activate /opt/idds; python3 -m pip install --no-cache-dir --upgrade pip
RUN source /etc/profile.d/conda.sh; conda activate /opt/idds; python3 -m pip install --no-cache-dir --upgrade setuptools

RUN source /etc/profile.d/conda.sh; conda activate /opt/idds; python3 -m pip install --no-cache-dir --upgrade requests SQLAlchemy urllib3 retrying mod_wsgi flask futures stomp.py cx-Oracle  unittest2 pep8 flake8 pytest nose sphinx recommonmark sphinx-rtd-theme nevergrad
RUN source /etc/profile.d/conda.sh; conda activate /opt/idds; python3 -m pip install --no-cache-dir --upgrade psycopg2-binary
RUN source /etc/profile.d/conda.sh; conda activate /opt/idds; python3 -m pip install --no-cache-dir --upgrade rucio-clients-atlas rucio-clients panda-client
RUN source /etc/profile.d/conda.sh; conda activate /opt/idds; python3 -m pip install --no-cache-dir --upgrade idds-common idds-workflow idds-server idds-client idds-doma idds-atlas idds-website idds-monitor

RUN mkdir /opt/idds/config
RUN mkdir /opt/idds/config/idds
# RUN mkdir /opt/idds/config_default

# ADD idds.cfg.default /opt/idds/config

# RUN ls /opt/idds/etc; ls /opt/idds/etc/idds; ls /opt/idds/etc/panda;
# RUN ls /opt/idds/config; ls /opt/idds/config/idds;

# for rest service
# RUN ln -fs /opt/idds/config/hostkey.pem /etc/grid-security/hostkey.pem
# RUN ln -fs /opt/idds/config/hostcert.pem /etc/grid-security/hostcert.pem

# to authenticate to rucio
RUN ln -fs /opt/idds/config/ca.crt /opt/idds/etc/ca.crt
RUN ln -fs /opt/idds/config/rucio.cfg /opt/idds/etc/rucio.cfg

# for panda client to access panda
RUN ln -fs /opt/idds/config/panda.cfg /opt/idds/etc/panda/panda.cfg

# for idds rest service
RUN ln -fs /opt/idds/config/idds/idds.cfg /opt/idds/etc/idds/idds.cfg
RUN ln -fs /opt/idds/config/idds/auth.cfg /opt/idds/etc/idds/auth/auth.cfg
RUN ln -fs /opt/idds/config/idds/gacl /opt/idds/etc/idds/rest/gacl
RUN ln -fs /opt/idds/config/idds/httpd-idds-443-py39-cc7.conf /etc/httpd/conf.d/httpd-idds-443-py39-cc7.conf

# for idds daemons
RUN ln -fs /opt/idds/config/idds/supervisord_idds.ini /etc/supervisord.d/idds.ini

ENV PATH /opt/idds/bin/:$PATH

ADD start-daemon.sh /opt/idds/bin/

VOLUME /var/log/idds
VOLUME /opt/idds/config

ENTRYPOINT ["start-daemon.sh"]

STOPSIGNAL SIGINT

EXPOSE 8443
CMD ["all"]
