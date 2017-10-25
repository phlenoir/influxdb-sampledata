#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="pcap replay (1 day of orders)"

# Number of tests
TOTAL_TESTS=56

OF_PREFIX="${0%.sh}"

echo "# drop database ###################################################################################"
${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -execute 'DROP DATABASE pcap'
assert_ran_ok "DROP DATABASE pcap"

echo "# create database #################################################################################"
${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -execute 'CREATE DATABASE pcap'
assert_ran_ok "CREATE DATABASE pcap"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 15_perf_kapacitor_pcap
assert_ran_ok "delete 15_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 15_perf_kapacitor_pcap -tick ${KAPACITOR_TICKDIR}/15_perf_kapacitor_pcap.tick -type stream -dbrp pcap.autogen
assert_ran_ok "define 15_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 15_perf_kapacitor_pcap
assert_ran_ok "enable 15_perf_kapacitor_pcap"

for filename in /app/influxdb/pcap/*.pcap; do

echo "# load $filename #################################################################################"
time \
${PCAP2INF} \
-dbip "127.0.0.1" \
-dbport 9092 \
-dbname pcap \
-blocksize 32000 \
-dbuser "optiq" \
-dbpwd "optiq" \
-in "$filename"
assert_ran_ok "pcap2inf $filename"

sleep 10

echo "# count points ####################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "pcap"."autogen"."orders"'
assert_ran_ok "count points in orders"

echo "# count series ####################################################################################"
${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -database 'pcap' -format 'csv' -execute 'SHOW SERIES' | grep -v "key" | wc -l
assert_ran_ok "count series in orders"

done


# Print results
report
