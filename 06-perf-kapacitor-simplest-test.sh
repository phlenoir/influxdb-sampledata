#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="kapacitor simplest task"

# Number of tests
TOTAL_TESTS=4

OF_PREFIX="${0%.sh}" # Expands to './01-foo-test'

${KAPACITOR_BIN} ${KAPACITOR_OPT} define 06_perf_simplest -tick ${KAPACITOR_TICKDIR}/06_perf_simplest.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define 06_perf_simplest"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 06_perf_simplest
assert_ran_ok "enable 06_perf_simplest"
#
${STARTGEN} -c ${OF_PREFIX}.yaml
sleep 30
${STOPGEN}
assert_ran_ok "Push data to Kapacitor, then Kapacitor sends these data to Influxdb"
#
${KAPACITOR_BIN} ${KAPACITOR_OPT} show 06_perf_simplest
assert_ran_ok "show 06_perf_simplest (see log file)"
#
# TODO clear data
#
# Print results
report
