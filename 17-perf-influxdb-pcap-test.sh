#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="pcap replay (1 day of orders) to InfluxDB"

# Number of tests
TOTAL_TESTS=56

OF_PREFIX="${0%.sh}"

echo "# drop database ###################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=DROP DATABASE pcap'
assert_ran_ok "DROP DATABASE pcap"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=DROP DATABASE optiq'
assert_ran_ok "DROP DATABASE optiq"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=CREATE DATABASE pcap with replication 2'
assert_ran_ok "CREATE DATABASE pcap"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=CREATE DATABASE optiq with replication 2'
assert_ran_ok "CREATE DATABASE optiq"


${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 17_perf_influxdb_pcap
assert_ran_ok "delete 17_perf_influxdb_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 17_perf_influxdb_pcap -tick ${KAPACITOR_TICKDIR}/17_perf_influxdb_pcap.tick -type stream -dbrp pcap.autogen
assert_ran_ok "define 17_perf_influxdb_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 17_perf_influxdb_pcap
assert_ran_ok "enable 17_perf_influxdb_pcap"

for filename in /app/influxdb/pcap/*.pcap; do

echo "# load $filename #################################################################################"
time \
${PCAP2INF} \
-dbip "172.26.160.10" \
-dbport 8086 \
-dbname pcap \
-blocksize 16000 \
-dbuser "optiq" \
-dbpwd "optiq" \
-in "$filename" &
#assert_ran_ok "pcap2inf $filename"

#sleep 10

#echo "# count points ####################################################################################"
#curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "pcap"."autogen"."orders"'
#assert_ran_ok "count points in orders"

#echo "# count series ####################################################################################"
#${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -database 'pcap' -format 'csv' -execute 'SHOW SERIES' | grep -v "key" | wc -l
#assert_ran_ok "count series in orders"

done


# Print results
report
