#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Unit test Kapacitor tasks"

# Number of tests
TOTAL_TESTS=18

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks simplest
assert_ran_ok "delete simplest"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 06_perf_simplest -tick ${KAPACITOR_TICKDIR}/06_perf_simplest.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define simplest"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable simplest
assert_ran_ok "enable simplest"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks two_tasks_arithmetic
assert_ran_ok "delete simplest"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 07_perf_join -tick ${KAPACITOR_TICKDIR}/07_perf_join.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define two_tasks_arithmetic"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable two_tasks_arithmetic
assert_ran_ok "enable two_tasks_arithmetic"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks mean_latency
assert_ran_ok "delete mean_latency"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 08_perf_mean_latency -tick ${KAPACITOR_TICKDIR}/08_perf_mean_latency.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define mean_latency"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable mean_latency
assert_ran_ok "enable mean_latency"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks mean_latency_1
assert_ran_ok "delete mean_latency_1"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define-template generic_mean_latency -tick ${KAPACITOR_TICKDIR}/mean_latency_template.tick -type stream
assert_ran_ok "define-template generic_mean_latency"
# define the task using the vars for the task (-dbrp refers to the source rp)
${KAPACITOR_BIN} ${KAPACITOR_OPT} define mean_latency_1 -template generic_mean_latency -vars ${KAPACITOR_TICKDIR}/latency_vars.json -dbrp trading.rp_unit
assert_ran_ok "define mean_latency_1"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable mean_latency_1
assert_ran_ok "enable mean_latency_1"

echo "######## CHECK"
${KAPACITOR_BIN} ${KAPACITOR_OPT} list tasks
assert_ran_ok "list tasks (see log file)"
echo "######## CLEAN-UP"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks simplest
assert_ran_ok "delete tasks simplest"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks two_tasks_arithmetic
assert_ran_ok "delete tasks two_tasks_arithmetic"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks mean_latency
assert_ran_ok "delete tasks mean_latency"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks mean_latency_1
assert_ran_ok "delete mean_latency_1"

# Print results
report
