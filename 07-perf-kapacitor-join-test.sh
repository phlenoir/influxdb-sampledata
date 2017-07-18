#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Push data to Kapacitor (60s)"

# Number of tests
TOTAL_TESTS=8

OF_PREFIX="${0%.sh}" # Expands to './01-foo-test'

${KAPACITOR_BIN} ${KAPACITOR_OPT} define two_tasks_arithmetic -tick ${KAPACITOR_TICKDIR}/two_tasks_arithmetic.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define two_tasks_arithmetic"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable two_tasks_arithmetic
assert_ran_ok "enable two_tasks_arithmetic"

${KAPACITOR_BIN} ${KAPACITOR_OPT} define-template generic_mean_latency -tick ${KAPACITOR_TICKDIR}/mean_latency_template.tick -type stream
assert_ran_ok "define-template generic_mean_latency"
# define the task using the vars for the task (-dbrp refers to the source rp)
${KAPACITOR_BIN} ${KAPACITOR_OPT} define mean_latency -template generic_mean_latency -vars ${KAPACITOR_TICKDIR}/latency_vars.json -dbrp trading.rp_unit
assert_ran_ok "define mean_latency"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable mean_latency
assert_ran_ok "enable mean_latency"

#
${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 60 --sampling 1
assert_ran_ok "Push data to Kapacitor, then Kapacitor sends these data to Influxdb"

${KAPACITOR_BIN} ${KAPACITOR_OPT} show two_tasks_arithmetic
assert_ran_ok "show two_tasks_arithmetic (see log file)"

${KAPACITOR_BIN} ${KAPACITOR_OPT} show mean_latency
assert_ran_ok "show mean_latency (see log file)"


# Print results
report
