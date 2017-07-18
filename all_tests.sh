#!/bin/bash
#set -x

./clean.sh

FAIL=0
#
# Run scenarios
#
for i in ./*-test.sh; do
    $i
    [[ $? -ne 0 ]] && FAIL=1
done

[[ $FAIL -ne 0 ]] && echo "ERROR: One or more test suites failed"
exit $FAIL
