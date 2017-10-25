#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="pcap replay (1 day of orders)"

# Number of tests
TOTAL_TESTS=44

OF_PREFIX="${0%.sh}"


echo "# create databases #################################################################################"
for((i=${#INFLUXDB_URLS[*]}-1;i>=0;i--))
do
  curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=DROP DATABASE pcap'
  assert_ran_ok "DROP DATABASE pcap"
  curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=DROP DATABASE optiq'
  assert_ran_ok "DROP DATABASE optiq"
  curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=CREATE DATABASE pcap'
  assert_ran_ok "CREATE DATABASE pcap"
  curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=CREATE DATABASE optiq'
  assert_ran_ok "CREATE DATABASE optiq"
done

echo "# create tasks #################################################################################"
for((i=${#KAPACITOR_URLS[*]}-1;i>=0;i--))
do
  ${KAPACITOR_BIN} -url ${KAPACITOR_URLS[i]} delete tasks 18_perf_kapacitor_pcap
  assert_ran_ok "delete 18_perf_kapacitor_pcap"
  ${KAPACITOR_BIN} -url ${KAPACITOR_URLS[i]} define 18_perf_kapacitor_pcap -tick ${KAPACITOR_TICKDIR}/18_perf_kapacitor_pcap.tick -type stream -dbrp pcap.autogen
  assert_ran_ok "define 18_perf_kapacitor_pcap"
  ${KAPACITOR_BIN} -url ${KAPACITOR_URLS[i]} enable 18_perf_kapacitor_pcap
  assert_ran_ok "enable 18_perf_kapacitor_pcap"
done

for filename in /app/influxdb/pcap/*.pcap; do

  echo "# load $filename #################################################################################"
  time \
  ${PCAP2INF} \
  -dbip "172.26.160.9" \
  -dbport 9092 \
  -dbname pcap \
  -blocksize 32000 \
  -dbuser "optiq" \
  -dbpwd "optiq" \
  -in "$filename"

  assert_ran_ok "pcap2inf $filename"

  sleep 10

  for((i=${#INFLUXDB_URLS[*]}-1;i>=0;i--))
  do
    echo "# count points $i ####################################################################################"
    curl -i -XPOST ${INFLUXDB_URLS[i]}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "optiq"."autogen"."orders"'
    assert_ran_ok "count points $i in optiq.orders"
  done

done

# Print results
report
