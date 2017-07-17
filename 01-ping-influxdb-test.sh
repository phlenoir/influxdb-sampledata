#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Check InfluxDB"

# Number of tests
TOTAL_TESTS=2

OF_PREFIX="${0%.sh}" # Expands to './01-foo-test'
curl -sl -I ${INFLUXDB_REST_ENDPOINT}/ping | head -1 | tee $OF_PREFIX-1.out
assert_ran_ok "${INFLUXDB_REST_ENDPOINT}/ping"
assert 'InfluxDB returned 204' \
  'diff -u $OF_PREFIX-1.cmp $OF_PREFIX-1.out'

# Print results
report
