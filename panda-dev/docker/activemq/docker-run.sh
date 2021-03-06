#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.



# This is the entry point for the docker images.
# This file is executed when docker run is called.


set -e

ACTIVEMQ_SERVICE=$1

BROKER_HOME=/var/lib/
CONFIG_PATH=$BROKER_HOME/artemis-instance/etc
export BROKER_HOME OVERRIDE_PATH CONFIG_PATH

if [[ ${ANONYMOUS_LOGIN,,} == "true" ]]; then
  LOGIN_OPTION="--allow-anonymous"
else
  LOGIN_OPTION="--require-login"
fi

CREATE_ARGUMENTS="--user ${ARTEMIS_USER} --password ${ARTEMIS_PASSWORD} --silent ${LOGIN_OPTION} ${EXTRA_ARGS}"

echo CREATE_ARGUMENTS=${CREATE_ARGUMENTS}

if ! [ -f ./etc/broker.xml ]; then
    /opt/activemq-artemis/bin/artemis create ${CREATE_ARGUMENTS} .
    mv ${CONFIG_PATH}/bootstrap.xml ${CONFIG_PATH}/bootstrap.xml.orig
    mv ${CONFIG_PATH}/broker.xml ${CONFIG_PATH}/broker.xml.orig
    mv ${CONFIG_PATH}/login.config ${CONFIG_PATH}/login.config.orig
    cp /opt/activemq-artemis/docker/conf/bootstrap.xml ${CONFIG_PATH}/bootstrap.xml
    cp /opt/activemq-artemis/docker/conf/broker.xml ${CONFIG_PATH}/broker.xml
    cp /opt/activemq-artemis/docker/conf/login.config ${CONFIG_PATH}/login.config

else
    echo "broker already created, ignoring creation"
fi

echo "ACTIVEMQ_SERVICE: ${ACTIVEMQ_SERVICE}"
if [ "${ACTIVEMQ_SERVICE}" == "run" ]; then
    exec ./bin/artemis "$@"
else
    exec "$@"
fi
