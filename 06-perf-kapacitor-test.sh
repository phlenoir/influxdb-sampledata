#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Push data to Kapacitor (60s)"

# Number of tests
TOTAL_TESTS=2

OF_PREFIX="${0%.sh}" # Expands to './01-foo-test'

#
${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 60 --sampling 1
assert_ran_ok "Push data to Kapacitor, then Kapacitor sends these data to Influxdb"
# TODO clear data

# Print results
report
