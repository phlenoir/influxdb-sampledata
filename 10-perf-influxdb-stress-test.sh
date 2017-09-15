#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="InfluxDB stress test"

# Number of tests
TOTAL_TESTS=12

OF_PREFIX="${0%.sh}"

echo "###################################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--host "http://172.26.160.10:8086" \
--points 1000000000 \
--pps 100000 \
--precision n \
--rp rp_stress \
--stats-host "http://172.26.160.10:8086" \
--strict \
--runtime 120s \
--series 100000 \
--stats \
--tick 1s \
test_10,segment=EQU,partition=P1,lc=192.168.1.1 t3=500i,t4=1000i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_10"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_10\" (see log file)"
sleep 10

echo "###################################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--host "http://172.26.160.10:8086" \
--points 1000000000 \
--pps 200000 \
--precision n \
--rp rp_stress \
--stats-host "http://172.26.160.10:8086" \
--strict \
--runtime 120s \
--series 100000 \
--stats \
--tick 1s \
test_10,segment=EQU,partition=P1,lc=192.168.1.1 t3=500i,t4=1000i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_10"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_10\" (see log file)"
sleep 10

echo "###################################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--host "http://172.26.160.10:8086" \
--points 1000000000 \
--pps 300000 \
--precision n \
--rp rp_stress \
--stats-host "http://172.26.160.10:8086" \
--strict \
--runtime 120s \
--series 100000 \
--stats \
--tick 1s \
test_10,segment=EQU,partition=P1,lc=192.168.1.1 t3=500i,t4=1000i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_10"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_10\" (see log file)"
sleep 10

echo "###################################################################################################"
${INFLUXSTRESS} insert \
--batch-size 30000 \
--db stress \
--host "http://172.26.160.10:8086" \
--points 1000000000 \
--pps 300000 \
--precision n \
--rp rp_stress \
--stats-host "http://172.26.160.10:8086" \
--strict \
--runtime 120s \
--series 100000 \
--stats \
--tick 1s \
test_10,segment=EQU,partition=P1,lc=192.168.1.1 t3=500i,t4=1000i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_10"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_10\" (see log file)"
sleep 10

echo "###################################################################################################"
${INFLUXSTRESS} insert \
--batch-size 30000 \
--db stress \
--host "http://172.26.160.10:8086" \
--points 1000000000 \
--pps 500000 \
--precision n \
--rp rp_stress \
--stats-host "http://172.26.160.10:8086" \
--strict \
--runtime 120s \
--series 100000 \
--stats \
--tick 1s \
test_10,segment=EQU,partition=P1,lc=192.168.1.1 t3=500i,t4=1000i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_10"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_10\" (see log file)"
sleep 10

echo "###################################################################################################"
${INFLUXSTRESS} insert \
--batch-size 30000 \
--db stress \
--host "http://172.26.160.10:8086" \
--points 1000000000 \
--pps 1000000 \
--precision n \
--rp rp_stress \
--stats-host "http://172.26.160.10:8086" \
--strict \
--runtime 120s \
--series 100000 \
--stats \
--tick 1s \
test_10,segment=EQU,partition=P1,lc=192.168.1.1 t3=500i,t4=1000i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_10"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_10\" (see log file)"

# Print results
report
