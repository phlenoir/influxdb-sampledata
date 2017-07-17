#!/bin/bash
#set -x

./clean.sh

FAIL=0
#
# Run scenarios
#
for i in ./*-test.sh; do
    $i
    [[ $? -ne 0 ]] && FAIL=1
done

[[ $FAIL -ne 0 ]] && echo "ERROR: One or more test suites failed"
exit $FAIL


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
${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 5 --sampling 1
# TODO clear data
################################################################################
# scenario
# push data to kapacitor
#${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 5 --sampling 1
