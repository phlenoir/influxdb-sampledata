#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Kapacitor stress test"

# Number of tests
TOTAL_TESTS=5

OF_PREFIX="${0%.sh}"


echo "###################################################################################################"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 12_perf_kapacitor_stress
assert_ran_ok "delete 12_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 12_perf_kapacitor_stress -tick ${KAPACITOR_TICKDIR}/12_perf_kapacitor_stress.tick -type stream -dbrp stress.rp_stress
assert_ran_ok "define 12_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 12_perf_kapacitor_stress
assert_ran_ok "enable 12_perf_kapacitor_stress"
echo "# 10,000 ##########################################################################################"
${INFLUXSTRESS} insert \
--batch-size 30000 \
--db stress \
--rp rp_stress \
--kapacitor \
--host "http://172.26.160.11:9092" \
--points 1000000000 \
--pps 270000 \
--precision n \
--strict \
--runtime 180s \
--series 20000 \
--tick 1s \
test_12_input,segment=EQU,partition=P1,lc=192.168.1.1 latNs=500i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_12"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_12\" (see log file)"

# Print results
report
