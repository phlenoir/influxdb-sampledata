#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="pcap replay (1 day of throughput)"

# Number of tests
TOTAL_TESTS=56

OF_PREFIX="${0%.sh}"

${KAPACITOR_BIN} ${KAPACITOR_OPT} delete tasks 16_perf_kapacitor_pcap
assert_ran_ok "delete 16_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define 16_perf_kapacitor_pcap -tick ${KAPACITOR_TICKDIR}/16_perf_kapacitor_pcap.tick -type stream -dbrp pcap.default
assert_ran_ok "define 16_perf_kapacitor_pcap"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable 16_perf_kapacitor_pcap
assert_ran_ok "enable 16_perf_kapacitor_pcap"

for filename in /app/influxdb/pcap/*.pcap; do

echo "# load $filename #################################################################################"
time \
${MDG2INDB} \
-dbip "172.26.160.10" \
-dbport 9092 \
-dbname pcap \
-blocksize 64000 \
-dbuser "optiq" \
-dbpwd "optiq" \
-in "$filename" \
-precision milli
assert_ran_ok "mdg2indb $filename"

sleep 10

echo "# count points ####################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "pcap"."autogen"."bytes"'
assert_ran_ok "count points in bytes"

echo "# count series ####################################################################################"
${INFLUXCLI_BIN} -host "172.26.160.10" -port 8086 -database 'pcap' -format 'csv' -execute 'SHOW SERIES' | grep -v "key" | wc -l
assert_ran_ok "count series"

done


# Print results
report
