#!/bin/bash
#set -x
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

function log() {
    printf "%.23s %s[%s]: %s\n" $(date +%F.%T.%N) ${BASH_SOURCE[1]##*/} ${BASH_LINENO[0]} "${@}";
}

function assert {
  # First parameter is the message in case the assertion is not verified
  message="$1"
  # Second paramter is the condition to check
  condition="$2"
  # If everything is okay, there's nothing left to do
  [ $condition ] && return 0
  # An error occured, retrieved the line and the name of the script where
  # it happend
  set $(caller)
  # Output an error message on the standard error
  # Format: date script [pid]: message (linenumber, return code)
  printf "%.23s %s[%s]: %s\n" $(date +%F.%T.%N) ${2##*/} $1 "$message"
  # Exit
  exit 1
}
#assert "not passing" "0 -eq 1"
##
# datagen accpets the following parameters :
#  --host HOST          hostname http API
#  --port PORT          port http API
#  --sec SEC            amount of seconds we will be pushing data to influxdb
#  --rate RATE          number of messages per second to send to influxdb
#  --sampling SAMPLING  number of times per second the rate is checked
##
#
# Ping Influxdb
assert "Please start/check Influxdb on ${INFLUXDB_REST_ENDPOINT} before running this script" \
        "204 -eq `curl -sl -I ${INFLUXDB_REST_ENDPOINT}/ping | head -1 | awk '{print $2}'`"
# Initialize InfluxDB
# create dabase
assert "Cannot create database trading" \
        "200 -eq `curl -i -XPOST ${INFLUXDB_REST_ENDPOINT}/query --data-urlencode 'q=CREATE DATABASE trading' | head -1 | awk '{print $2}'`"
# create retention policies
assert "Cannot drop retention policy rp_unit" \
        "200 -eq `curl -i -XPOST ${INFLUXDB_REST_ENDPOINT}/query --data-urlencode 'q=DROP RETENTION POLICY \"rp_unit\" ON \"trading\"' | head -1 | awk '{print $2}'`"
assert "Cannot drop retention policy rp_agg" \
        "200 -eq `curl -i -XPOST ${INFLUXDB_REST_ENDPOINT}/query --data-urlencode 'q=DROP RETENTION POLICY \"rp_agg\" ON \"trading\"' | head -1 | awk '{print $2}'`"
assert "Cannot create retention policy rp_unit" \
        "200 -eq `curl -i -XPOST ${INFLUXDB_REST_ENDPOINT}/query --data-urlencode 'q=CREATE RETENTION POLICY \"rp_agg\" ON \"trading\" DURATION 1d REPLICATION 1' | head -1 | awk '{print $2}'`"
#
# Ping Kapacitor
assert "Please start/check Kapacitor on ${KAPACITOR_REST_ENDPOINT} before running this script" \
        "204 -eq `curl -sl -I ${KAPACITOR_REST_ENDPOINT}/kapacitor/v1/ping | head -1 | awk '{print $2}'`"
#
# Run scenarios
#
################################################################################
# scenario
log "Push data direcly to InfluxDB"
${DATAGEN} --host ${INFLUXDB_HOSTIP} --port 8089 --sec 500 --sampling 1
# TODO clear data
################################################################################
# scenario
log "Push data to Kapacitor, then Kapacitor sends these data to Influxdb"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define simplest -tick ${BASEDIR}/kapacitor/tasks/simplest.tick -type stream -dbrp trading.rp_unit
sleep 1
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable simplest
sleep 1
${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 5 --sampling 1
# TODO clear data
################################################################################
# scenario
# push data to kapacitor
#${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 5 --sampling 1
