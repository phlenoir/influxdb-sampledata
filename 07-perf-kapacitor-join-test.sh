#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="two_tasks_arithmetic (30s)"

# Number of tests
TOTAL_TESTS=5

OF_PREFIX="${0%.sh}"

${KAPACITOR_BIN} ${KAPACITOR_OPT} define 07_perf_join -tick ${KAPACITOR_TICKDIR}/07_perf_join.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define 07_perf_join"
echo "###################################################################################################"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 07_perf_join
assert_ran_ok "enable 07_perf_join"
echo "###################################################################################################"
${STARTGEN} -c ${OF_PREFIX}.yaml
sleep 30
${STOPGEN}
assert_ran_ok "Push data to Kapacitor, then Kapacitor sends these data to Influxdb"
echo "###################################################################################################"
echo "# Check InfluxDB parameters in etc/influxdb/infludb.conf !!!"
echo "# max-series-per-database = 1000000"
echo "# -------------------------------------------------------------------------------------------------"
echo "${KAPACITOR_BIN} ${KAPACITOR_OPT} show 07_perf_join"
${KAPACITOR_BIN} ${KAPACITOR_OPT} show 07_perf_join
assert_ran_ok "show two_tasks_arithmetic (see log file)"
echo "###################################################################################################"
echo "curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from \"trading\".\"rp_unit\".\"oeg.latency.sample\"'"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "trading"."rp_unit"."oeg.latency.sample"'
assert_ran_ok "count(*) oeg.latency.sample (see log file)"

# Print results
report
