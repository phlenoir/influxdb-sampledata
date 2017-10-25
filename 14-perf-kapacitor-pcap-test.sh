#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="pcap replay (1 hour of orders)"

# Number of tests
TOTAL_TESTS=12

OF_PREFIX="${0%.sh}"

if false ; then

echo "# create database #################################################################################"
${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -execute 'CREATE DATABASE pcap'
assert_ran_ok "CREATE DATABASE pcap"

echo "# run test ########################################################################################"
time \
${PCAP2INF} \
-dbip "172.26.160.10" \
-dbport 8086 \
-dbname pcap \
-blocksize 32000 \
-dbuser "optiq" \
-dbpwd "optiq" \
-in /home/opcon/idbVolumes/out.pcap
assert_ran_ok "pcap2inf"

# let kapacitor flush the data
sleep 10

echo "# count points ####################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "pcap"."autogen"."orders"'
assert_ran_ok "count points in orders"

echo "# count series ####################################################################################"
${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -database 'pcap' -format 'csv' -execute 'SHOW SERIES' | grep -v "key" | wc -l
assert_ran_ok "count series in orders"

echo "# drop database ###################################################################################"
${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -execute 'DROP DATABASE pcap'
assert_ran_ok "DROP DATABASE pcap"

fi

echo "# create database #################################################################################"
${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -execute 'CREATE DATABASE pcap'
assert_ran_ok "CREATE DATABASE pcap"
echo "###################################################################################################"
${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 14_perf_kapacitor_pcap
assert_ran_ok "delete 14_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 14_perf_kapacitor_pcap -tick ${KAPACITOR_TICKDIR}/14_perf_kapacitor_pcap.tick -type stream -dbrp pcap.autogen
assert_ran_ok "define 14_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 14_perf_kapacitor_pcap
assert_ran_ok "enable 14_perf_kapacitor_pcap"

echo "# run test ########################################################################################"
time \
${PCAP2INF} \
-dbip "172.26.160.11" \
-dbport 9092 \
-dbname pcap \
-blocksize 32000 \
-dbuser "optiq" \
-dbpwd "optiq" \
-in /home/opcon/idbVolumes/out.pcap
assert_ran_ok "pcap2inf"

echo "# count points ####################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "pcap"."autogen"."orders"'
assert_ran_ok "count points in orders"

echo "# count series ####################################################################################"
${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -database 'pcap' -format 'csv' -execute 'SHOW SERIES' | grep -v "key" | wc -l
assert_ran_ok "count series in orders"

#echo "# drop database ###################################################################################"
#${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -execute 'DROP DATABASE pcap'
#assert_ran_ok "DROP DATABASE pcap"


# Print results
report
