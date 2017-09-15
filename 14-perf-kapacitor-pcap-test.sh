#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="pcap replay"

# Number of tests
TOTAL_TESTS=2

OF_PREFIX="${0%.sh}"


echo "# 10,000 ##########################################################################################"
${PCAP2INF} \
-dbip "172.26.160.10" \
-dbport 8086 \
-dbname ppe \
-blocksize 32000 \
-dbuser "optiq" \
-dbpwd "optiq" \
-in /home/opcon/idbVolumes/out.pcap
assert_ran_ok "pcap2inf"

echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "ppe"."autogen"."orders"'
assert_ran_ok "SELECT count(*) from \"ppe\".\"orders\" (see log file)"

# Print results
report
