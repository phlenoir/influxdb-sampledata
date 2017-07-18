#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Push data direcly to InfluxDB (60s)"

# Number of tests
TOTAL_TESTS=2

OF_PREFIX="${0%.sh}"

#
${DATAGEN} --host ${INFLUXDB_HOSTIP} --port 8089 --sec 60 --sampling 1
assert_ran_ok "Push data direcly to InfluxDB"
# TODO clear data

# Print results
report
