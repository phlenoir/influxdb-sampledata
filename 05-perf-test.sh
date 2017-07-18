#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Check InfluxDB"

# Number of tests
TOTAL_TESTS=2

OF_PREFIX="${0%.sh}" # Expands to './01-foo-test'

#
# Run scenarios
#
################################################################################
# scenario #1
${DATAGEN} --host ${INFLUXDB_HOSTIP} --port 8089 --sec 500 --sampling 1
assert_ran_ok "Push data direcly to InfluxDB"
# TODO clear data
################################################################################
# scenario #2
${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 5 --sampling 1
assert_ran_ok "Push data to Kapacitor, then Kapacitor sends these data to Influxdb"
# TODO clear data
################################################################################
# scenario #3
#${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 5 --sampling 1
#assert_ran_ok "Push data to Kapacitor"

# Print results
report
