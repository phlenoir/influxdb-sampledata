#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Drop database 'trading'"

# Number of tests
TOTAL_TESTS=2

OF_PREFIX="${0%.sh}"
curl -i -XPOST ${INFLUXDB_URL}/query --data-urlencode 'q=DROP DATABASE "trading"' | head -1 | tee $OF_PREFIX-1.out
assert_ran_ok "DROP DATABASE trading"
assert 'InfluxDB returned 200' \
  'diff -u $OF_PREFIX-1.cmp $OF_PREFIX-1.out'

# Print results
report
