#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Initialize InfluxDB"

# Number of tests
TOTAL_TESTS=10

OF_PREFIX="${0%.sh}" # Expands to './01-foo-test'
curl -i -XPOST ${INFLUXDB_URL}/query --data-urlencode 'q=CREATE DATABASE trading' | head -1 | tee $OF_PREFIX-1.out
assert_ran_ok "CREATE DATABASE trading"
assert 'InfluxDB returned 200' \
  'diff -u $OF_PREFIX-1.cmp $OF_PREFIX-1.out'

curl -i -XPOST ${INFLUXDB_URL}/query --data-urlencode 'q=DROP RETENTION POLICY "rp_unit" ON "trading"' | head -1 | tee $OF_PREFIX-2.out
assert_ran_ok "DROP RETENTION POLICY \"rp_unit\""
assert 'InfluxDB returned 200' \
  'diff -u $OF_PREFIX-2.cmp $OF_PREFIX-2.out'

curl -i -XPOST ${INFLUXDB_URL}/query --data-urlencode 'q=CREATE RETENTION POLICY "rp_unit" ON "trading" DURATION 2d REPLICATION 1 DEFAULT' | head -1 | tee $OF_PREFIX-3.out
assert_ran_ok "CREATE RETENTION POLICY \"rp_unit\""
assert 'InfluxDB returned 200' \
  'diff -u $OF_PREFIX-3.cmp $OF_PREFIX-3.out'

curl -i -XPOST ${INFLUXDB_URL}/query --data-urlencode 'q=DROP RETENTION POLICY "rp_agg" ON "trading"' | head -1 | tee $OF_PREFIX-4.out
assert_ran_ok "DROP RETENTION POLICY \"rp_agg\""
assert 'InfluxDB returned 200' \
  'diff -u $OF_PREFIX-4.cmp $OF_PREFIX-4.out'

curl -i -XPOST ${INFLUXDB_URL}/query --data-urlencode 'q=CREATE RETENTION POLICY "rp_agg" ON "trading" DURATION 7d REPLICATION 1' | head -1 | tee $OF_PREFIX-5.out
assert_ran_ok "CREATE RETENTION POLICY \"rp_agg\""
assert 'InfluxDB returned 200' \
  'diff -u $OF_PREFIX-5.cmp $OF_PREFIX-5.out'

# Print results
report
