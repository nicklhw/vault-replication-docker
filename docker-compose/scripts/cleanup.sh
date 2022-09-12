#!/bin/bash

DIR="$( cd .. && pwd )"

# This script will clean up locally provisioned resources
rm -f *.json
git reset
git checkout ${DIR}/haproxy_int/haproxy.cfg
git checkout ${DIR}/haproxy_c1/haproxy.cfg
cd ../ && docker-compose down