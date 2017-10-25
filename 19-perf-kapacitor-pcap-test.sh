#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="pcap replay (1 day of orders - 2 I db and 2 layers of K)"

# Number of tests
TOTAL_TESTS=104

OF_PREFIX="${0%.sh}"

for((i=${#INFLUXDB_URLS[*]}-1;i>=0;i--))
do
  echo "# CREATE DATABASE #################################################################################"
  curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=DROP DATABASE optiq'
  assert_ran_ok "DROP DATABASE optiq"
  curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=DROP DATABASE pcap'
  assert_ran_ok "DROP DATABASE pcap"
  curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=CREATE DATABASE optiq'
  assert_ran_ok "CREATE DATABASE optiq"
  curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=CREATE DATABASE pcap'
  assert_ran_ok "CREATE DATABASE pcap"
  echo "# CREATE SUBSCRIPTION #############################################################################"
  curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=CREATE SUBSCRIPTION "sub_pcap" ON "pcap"."autogen" DESTINATIONS ALL '"'"'http://localhost:9092'"'"''
  assert_ran_ok "CREATE SUBSCRIPTION sub_pcap"
done

${KAPACITOR_BIN} -url ${KAPACITOR_URL} delete tasks 19_perf_kapacitor_L1
assert_ran_ok "delete 19_perf_kapacitor_L1"
${KAPACITOR_BIN} -url ${KAPACITOR_URL} define 19_perf_kapacitor_L1 -tick ${KAPACITOR_TICKDIR}/19_perf_kapacitor_L1.tick -type stream -dbrp pcap.autogen
assert_ran_ok "define 19_perf_kapacitor_L1"
${KAPACITOR_BIN} -url ${KAPACITOR_URL} enable 19_perf_kapacitor_L1
assert_ran_ok "enable 19_perf_kapacitor_L1"

echo "# create tasks #################################################################################"
for((i=${#KAPACITOR_URLS[*]}-1;i>=0;i--))
do
  ${KAPACITOR_BIN} -url ${KAPACITOR_URLS[i]} delete tasks 19_perf_kapacitor_L2
  assert_ran_ok "delete 19_perf_kapacitor_L2"
  ${KAPACITOR_BIN} -url ${KAPACITOR_URLS[i]} define 19_perf_kapacitor_L2 -tick ${KAPACITOR_TICKDIR}/19_perf_kapacitor_L2.tick -type stream -dbrp pcap.autogen
  assert_ran_ok "define 19_perf_kapacitor_L2"
  ${KAPACITOR_BIN} -url ${KAPACITOR_URLS[i]} enable 19_perf_kapacitor_L2
  assert_ran_ok "enable 19_perf_kapacitor_L2"
done

for filename in /app/influxdb/pcap/*.pcap; do

  echo "# load $filename #################################################################################"
  time \
  ${PCAP2INF} \
  -dbip "172.26.160.9" \
  -dbport 9092 \
  -dbname pcap \
  -measure in_orders \
  -blocksize 32000 \
  -dbuser "optiq" \
  -dbpwd "optiq" \
  -in "$filename"

  assert_ran_ok "pcap2inf $filename"

  sleep 10

  for((i=${#INFLUXDB_URLS[*]}-1;i>=0;i--))
  do
    echo "# count points in pcap.in_orders $i #############################################################"
    curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "pcap"."autogen"."in_orders"'
    assert_ran_ok "count points $i in pcap.in_orders"
    echo "# count points in optiq.ordersstats $i ##########################################################"
    curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "optiq"."autogen"."orderstats"'
    assert_ran_ok "count points $i in optiq.ordersstats"
  done

done

# Print results
report
