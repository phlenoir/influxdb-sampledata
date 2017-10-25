#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Unit test Kapacitor tasks"

# Number of tests
TOTAL_TESTS=54

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 06_perf_simplest
assert_ran_ok "delete 06_perf_simplest"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 06_perf_simplest -tick ${KAPACITOR_TICKDIR}/06_perf_simplest.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define 06_perf_simplest"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 06_perf_simplest
assert_ran_ok "enable 06_perf_simplest"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 07_perf_join
assert_ran_ok "delete 07_perf_join"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 07_perf_join -tick ${KAPACITOR_TICKDIR}/07_perf_join.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define 07_perf_join"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 07_perf_join
assert_ran_ok "enable 07_perf_join"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 08_perf_mean_latency
assert_ran_ok "delete 08_perf_mean_latency"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 08_perf_mean_latency -tick ${KAPACITOR_TICKDIR}/08_perf_mean_latency.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define 08_perf_mean_latency"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 08_perf_mean_latency
assert_ran_ok "enable 08_perf_mean_latency"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 09_perf_all_latencies
assert_ran_ok "delete 09_perf_all_latencies"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 09_perf_all_latencies -tick ${KAPACITOR_TICKDIR}/09_perf_all_latencies.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define 09_perf_all_latencies"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 09_perf_all_latencies
assert_ran_ok "enable 09_perf_all_latencies"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks mean_latency_1
assert_ran_ok "delete mean_latency_1"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define-template generic_mean_latency -tick ${KAPACITOR_TICKDIR}/mean_latency_template.tick -type stream
assert_ran_ok "define-template generic_mean_latency"
# define the task using the vars for the task (-dbrp refers to the source rp)
${KAPACITOR_BIN} ${KAPACITOR_OPT} define mean_latency_1 -template generic_mean_latency -vars ${KAPACITOR_TICKDIR}/latency_vars.json -dbrp trading.rp_unit
assert_ran_ok "define mean_latency_1"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable mean_latency_1
assert_ran_ok "enable mean_latency_1"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 11_perf_kapacitor_stress
assert_ran_ok "delete 11_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 11_perf_kapacitor_stress -tick ${KAPACITOR_TICKDIR}/11_perf_kapacitor_stress.tick -type stream -dbrp stress.rp_stress
assert_ran_ok "define 11_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 11_perf_kapacitor_stress
assert_ran_ok "enable 11_perf_kapacitor_stress"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 12_perf_kapacitor_stress
assert_ran_ok "delete 12_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 12_perf_kapacitor_stress -tick ${KAPACITOR_TICKDIR}/12_perf_kapacitor_stress.tick -type stream -dbrp stress.rp_stress
assert_ran_ok "define 12_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 12_perf_kapacitor_stress
assert_ran_ok "enable 11_perf_kapacitor_stress"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 13_perf_kapacitor_stress
assert_ran_ok "delete 13_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 13_perf_kapacitor_stress -tick ${KAPACITOR_TICKDIR}/13_perf_kapacitor_stress.tick -type stream -dbrp stress.rp_stress
assert_ran_ok "define 13_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 13_perf_kapacitor_stress
assert_ran_ok "enable 13_perf_kapacitor_stress"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 14_perf_kapacitor_pcap
assert_ran_ok "delete 14_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 14_perf_kapacitor_pcap -tick ${KAPACITOR_TICKDIR}/14_perf_kapacitor_pcap.tick -type stream -dbrp pcap.autogen
assert_ran_ok "define 14_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 14_perf_kapacitor_pcap
assert_ran_ok "enable 14_perf_kapacitor_pcap"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 15_perf_kapacitor_pcap
assert_ran_ok "delete 15_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 15_perf_kapacitor_pcap -tick ${KAPACITOR_TICKDIR}/15_perf_kapacitor_pcap.tick -type stream -dbrp pcap.autogen
assert_ran_ok "define 15_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 15_perf_kapacitor_pcap
assert_ran_ok "enable 15_perf_kapacitor_pcap"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 16_perf_kapacitor_pcap
assert_ran_ok "delete 16_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 16_perf_kapacitor_pcap -tick ${KAPACITOR_TICKDIR}/16_perf_kapacitor_pcap.tick -type stream -dbrp pcap.autogen
assert_ran_ok "define 16_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 16_perf_kapacitor_pcap
assert_ran_ok "enable 16_perf_kapacitor_pcap"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 17_perf_influxdb_pcap
assert_ran_ok "delete 17_perf_influxdb_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 17_perf_influxdb_pcap -tick ${KAPACITOR_TICKDIR}/17_perf_influxdb_pcap.tick -type stream -dbrp pcap.autogen
assert_ran_ok "define 17_perf_influxdb_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 17_perf_influxdb_pcap
assert_ran_ok "enable 17_perf_influxdb_pcap"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 18_perf_kapacitor_pcap
assert_ran_ok "delete 18_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 18_perf_kapacitor_pcap -tick ${KAPACITOR_TICKDIR}/18_perf_kapacitor_pcap.tick -type stream -dbrp pcap.autogen
assert_ran_ok "define 18_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 18_perf_kapacitor_pcap
assert_ran_ok "enable 18_perf_kapacitor_pcap"

echo "######## CHECK"
${KAPACITOR_BIN} ${KAPACITOR_OPT} list tasks
assert_ran_ok "list tasks (see log file)"
echo "######## CLEAN-UP"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 06_perf_simplest
assert_ran_ok "delete tasks 06_perf_simplest"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 07_perf_join
assert_ran_ok "delete tasks 07_perf_join"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 08_perf_mean_latency
assert_ran_ok "delete tasks 08_perf_mean_latency"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 09_perf_all_latencies
assert_ran_ok "delete tasks 09_perf_all_latencies"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks mean_latency_1
assert_ran_ok "delete mean_latency_1"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 11_perf_kapacitor_stress
assert_ran_ok "delete 11_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 12_perf_kapacitor_stress
assert_ran_ok "delete 12_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 13_perf_kapacitor_stress
assert_ran_ok "delete 13_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 14_perf_kapacitor_pcap
assert_ran_ok "delete 14_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 15_perf_kapacitor_pcap
assert_ran_ok "delete 15_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 16_perf_kapacitor_pcap
assert_ran_ok "delete 16_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 17_perf_influxdb_pcap
assert_ran_ok "delete 17_perf_influxdb_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 18_perf_kapacitor_pcap
assert_ran_ok "delete 18_perf_kapacitor_pcap"

# Print results
report
