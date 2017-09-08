#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="all_latencies (2h)"

# Number of tests
TOTAL_TESTS=6

OF_PREFIX="${0%.sh}"

echo "curl -i -XPOST '${INFLUXDB_URL}/query?db=trading&pretty=true' --data-urlencode 'q=DROP MEASUREMENT \"oeg.latencies.mean.measure\"'"
curl -i -XPOST 'http://qpdpecon24102-int:8086/query?db=trading&pretty=true' --data-urlencode 'q=DROP MEASUREMENT "oeg.latencies.mean.measure"'
assert_ran_ok "DROP MEASUREMENT oeg.latencies.mean.measure (see log file)"
echo "###################################################################################################"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 09_perf_all_latencies -tick ${KAPACITOR_TICKDIR}/09_perf_all_latencies.tick -type stream -dbrp trading.rp_unit
assert_ran_ok "define all_latencies"
echo "###################################################################################################"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 09_perf_all_latencies
assert_ran_ok "enable 09_perf_all_latencies"
echo "###################################################################################################"
${STARTGEN} -c ${OF_PREFIX}.yaml
sleep 7200
${STOPGEN}
assert_ran_ok "Push data to Kapacitor"
echo "###################################################################################################"
echo "${KAPACITOR_BIN} ${KAPACITOR_OPT} show 09_perf_all_latencies"
${KAPACITOR_BIN} ${KAPACITOR_OPT} show 09_perf_all_latencies
assert_ran_ok "show 09_perf_all_latencies (see log file)"
echo "###################################################################################################"
echo "curl -i -XPOST '${INFLUXDB_URL}/query?db=trading&pretty=true' --data-urlencode 'q=SELECT count(*) from \"rp_agg\".\"oeg.latencies.mean.measure\"'"
curl -i -XPOST '${INFLUXDB_URL}/query?db=trading&pretty=true' --data-urlencode 'q=SELECT count(*) from "rp_agg"."oeg.latencies.mean.measure"'
assert_ran_ok "count(*) oeg.latencies.mean.measure (see log file)"

# Print results
report
