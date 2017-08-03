#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Push data directly to InfluxDB (http)"

# Number of tests
TOTAL_TESTS=3

OF_PREFIX="${0%.sh}"

#
${STARTGEN} -c ${OF_PREFIX}.yaml
sleep 30
${STOPGEN}
assert_ran_ok "Push data directly to InfluxDB (http)"
#
echo "###################################################################################################"
echo "# Check InfluxDB parameters in etc/influxdb/infludb.conf !!!"
echo "# -------------------------------------------------------------------------------------------------"
echo "# The maximum number of tag values per tag that are allowed before writes are dropped.  This limit"
echo "# can prevent high cardinality tag values from being written to a measurement.  This limit can be"
echo "# disabled by setting it to 0."
echo "# max-values-per-tag = 100000"
echo "# -------------------------------------------------------------------------------------------------"
echo "# Since order ID is used as a tag in the datagen simulator, this limit maybe exceeded"
echo "###################################################################################################"
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "trading"."rp_unit"."oeg.ack-out.sample"'
assert_ran_ok "count(*) oeg.ack-out.sample (see log file)"
#
curl -i -XPOST ${INFLUXDB_URL}/query?pretty=true --data-urlencode 'q=SELECT count(*) from "trading"."rp_unit"."oeg.tor-out.sample"'
assert_ran_ok "count(*) oeg.oeg.tor-out.sample (see log file)"
#
# TODO clear data
#
# Print results
report
