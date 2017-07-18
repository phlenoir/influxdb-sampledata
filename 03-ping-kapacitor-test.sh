#!/bin/bash
#set -x
# Load the testing framework
. ./testlib.sh
. ./test_setup.sh

TEST_SUITE_NAME="Check Kapacitor"

# Number of tests
TOTAL_TESTS=2

OF_PREFIX="${0%.sh}" # Expands to './01-foo-test'
curl -sl -I ${KAPACITOR_URL}/kapacitor/v1/ping | head -1 | tee $OF_PREFIX-1.out
assert_ran_ok "${KAPACITOR_URL}/kapacitor/v1/ping"
assert 'Kapacitor REST API returned 204' \
  'diff -u $OF_PREFIX-1.cmp $OF_PREFIX-1.out'

# Print results
report
