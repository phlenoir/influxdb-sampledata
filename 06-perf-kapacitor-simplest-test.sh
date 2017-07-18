#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="simplest task (60s)"

# Number of tests
TOTAL_TESTS=4

OF_PREFIX="${0%.sh}" # Expands to './01-foo-test'

${KAPACITOR_BIN} ${KAPACITOR_OPT} define simplest -tick ${KAPACITOR_TICKDIR}/simplest.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define simplest"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable simplest
assert_ran_ok "enable simplest"
#
${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 60 --sampling 1
assert_ran_ok "Push data to Kapacitor, then Kapacitor sends these data to Influxdb"

${KAPACITOR_BIN} ${KAPACITOR_OPT} show simplest
assert_ran_ok "show simplest (see log file)"

# TODO clear data

# Print results
report
