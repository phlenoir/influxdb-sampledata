#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Kapacitor stress test"

# Number of tests
TOTAL_TESTS=17

OF_PREFIX="${0%.sh}"


echo "###################################################################################################"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 11_perf_kapacitor_stress
assert_ran_ok "delete 11_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 11_perf_kapacitor_stress -tick ${KAPACITOR_TICKDIR}/11_perf_kapacitor_stress.tick -type stream -dbrp stress.rp_stress
assert_ran_ok "define 11_perf_kapacitor_stress"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 11_perf_kapacitor_stress
assert_ran_ok "enable 11_perf_kapacitor_stress"
echo "# 10,000 ##########################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--rp rp_stress \
--kapacitor \
--host "http://172.26.160.11:9092" \
--points 1000000000 \
--pps 10000 \
--precision n \
--strict \
--runtime 180s \
--series 1000 \
--tick 1s \
test_11_input,segment=EQU,partition=P1,lc=192.168.1.1 latNs=500i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_11"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_11\" (see log file)"
echo "# 20,000 ##########################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--rp rp_stress \
--kapacitor \
--host "http://172.26.160.11:9092" \
--points 1000000000 \
--pps 20000 \
--precision n \
--strict \
--runtime 180s \
--series 1000 \
--tick 1s \
test_11_input,segment=EQU,partition=P1,lc=192.168.1.1 latNs=500i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_11"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_11\" (see log file)"
echo "# 50,000 ##########################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--rp rp_stress \
--kapacitor \
--host "http://172.26.160.11:9092" \
--points 1000000000 \
--pps 50000 \
--precision n \
--strict \
--runtime 180s \
--series 1000 \
--tick 1s \
test_11_input,segment=EQU,partition=P1,lc=192.168.1.1 latNs=500i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_11"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_11\" (see log file)"
echo "# 100,000 #########################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--rp rp_stress \
--kapacitor \
--host "http://172.26.160.11:9092" \
--points 1000000000 \
--pps 100000 \
--precision n \
--strict \
--runtime 180s \
--series 1000 \
--tick 1s \
test_11_input,segment=EQU,partition=P1,lc=192.168.1.1 latNs=500i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_11"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_11\" (see log file)"
echo "# 120,000 #########################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--rp rp_stress \
--kapacitor \
--host "http://172.26.160.11:9092" \
--points 1000000000 \
--pps 120000 \
--precision n \
--strict \
--runtime 180s \
--series 1000 \
--tick 1s \
test_11_input,segment=EQU,partition=P1,lc=192.168.1.1 latNs=500i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_11"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_11\" (see log file)"
echo "# 150,000 #########################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--rp rp_stress \
--kapacitor \
--host "http://172.26.160.11:9092" \
--points 1000000000 \
--pps 150000 \
--precision n \
--strict \
--runtime 180s \
--series 1000 \
--tick 1s \
test_11_input,segment=EQU,partition=P1,lc=192.168.1.1 latNs=500i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_11"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_11\" (see log file)"
echo "# 200,000 #########################################################################################"
${INFLUXSTRESS} insert \
--batch-size 10000 \
--db stress \
--rp rp_stress \
--kapacitor \
--host "http://172.26.160.11:9092" \
--points 1000000000 \
--pps 200000 \
--precision n \
--strict \
--runtime 180s \
--series 1000 \
--tick 1s \
test_11_input,segment=EQU,partition=P1,lc=192.168.1.1 latNs=500i
assert_ran_ok "influx-stress"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "stress"."rp_stress"."test_11"'
assert_ran_ok "SELECT count(*) from \"stress\".\"rp_stress\".\"test_11\" (see log file)"

# Print results
report
