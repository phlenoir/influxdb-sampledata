#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="stress test"

# Number of tests
TOTAL_TESTS=2

OF_PREFIX="${0%.sh}"

echo "###################################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db trading \
--host "http://172.26.160.10:8086" \
--pps 200000 \
--precision n \
--rp rp_unit \
--stats-host "http://172.26.160.10:8086" \
--strict \
--runtime 30s \
--series 100000 \
--stats \
--tick 1s
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_unit"."oeg.ack-out.sample"'
assert_ran_ok "count(*) oeg.ack-out.sample (see log file)"

# Print results
report
