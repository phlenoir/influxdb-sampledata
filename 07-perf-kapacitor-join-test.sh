#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="two_tasks_arithmetic (60s)"

# Number of tests
TOTAL_TESTS=5

OF_PREFIX="${0%.sh}"

${KAPACITOR_BIN} ${KAPACITOR_OPT} define two_tasks_arithmetic -tick ${KAPACITOR_TICKDIR}/two_tasks_arithmetic.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define two_tasks_arithmetic"
echo "###################################################################################################"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable two_tasks_arithmetic
assert_ran_ok "enable two_tasks_arithmetic"
echo "###################################################################################################"
${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 60 --sampling 1
assert_ran_ok "Push data to Kapacitor, then Kapacitor sends these data to Influxdb"
echo "###################################################################################################"
echo "# Check InfluxDB parameters in etc/influxdb/infludb.conf !!!"
echo "# max-series-per-database = 1000000"
echo "# -------------------------------------------------------------------------------------------------"
echo "${KAPACITOR_BIN} ${KAPACITOR_OPT} show two_tasks_arithmetic"
${KAPACITOR_BIN} ${KAPACITOR_OPT} show two_tasks_arithmetic
assert_ran_ok "show two_tasks_arithmetic (see log file)"
echo "###################################################################################################"
echo "curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from \"trading\".\"rp_unit\".\"oeg.latency.sample\"'"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "trading"."rp_unit"."oeg.latency.sample"'
assert_ran_ok "count(*) oeg.latency.sample (see log file)"

# Print results
report
