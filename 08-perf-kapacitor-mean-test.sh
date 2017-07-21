#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="mean_latency (60s)"

# Number of tests
TOTAL_TESTS=5

OF_PREFIX="${0%.sh}" 

${KAPACITOR_BIN} ${KAPACITOR_OPT} define mean_latency -tick ${KAPACITOR_TICKDIR}/mean_latency.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define mean_latency"
echo "###################################################################################################"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable mean_latency
assert_ran_ok "enable mean_latency"
echo "###################################################################################################"
${DATAGEN} --host ${KAPACITOR_HOSTIP} --port 9100 --sec 7200 --sampling 1
assert_ran_ok "Push data to Kapacitor"
echo "###################################################################################################"
echo "${KAPACITOR_BIN} ${KAPACITOR_OPT} show mean_latency"
${KAPACITOR_BIN} ${KAPACITOR_OPT} show mean_latency
assert_ran_ok "show mean_latency (see log file)"
echo "###################################################################################################"
echo "curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from \"trading\".\"rp_agg\".\"oeg.latency.mean.measure\"'"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "trading"."rp_agg"."oeg.latency.mean.measure"'
assert_ran_ok "count(*) oeg.latency.mean.measure (see log file)"

# Print results
report
