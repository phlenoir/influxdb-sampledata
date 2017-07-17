#!/bin/bash
export BASEDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Use onload to bypass the Kernel
#export DATAGEN="onload python ${BASEDIR}/datagen/datagen.py"
export DATAGEN="python ${BASEDIR}/datagen/datagen.py"
# Don't use dnsname in python script or the DNS server will be pinged for EVERY request sent
export INFLUXDB_HOSTIP=172.26.160.10
export KAPACITOR_HOSTIP=172.26.160.11

export INFLUXDB_REST_ENDPOINT="http://qpdpecon24102-int:8086"
export KAPACITOR_REST_ENDPOINT="http://qpdpecon24103-int:9092"

# TODO make http REST requets instead of binary call
export KAPACITOR_ROOT=${BASEDIR}/kapacitor-1.3.1-1
export KAPACITOR_BIN=${KAPACITOR_ROOT}/usr/bin/kapacitor
export KAPACITOR_OPT="-url ${KAPACITOR_REST_ENDPOINT}"
export KAPACITOR_TICKDIR=${BASEDIR}/kapacitor/tasks
