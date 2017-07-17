#!/bin/bash
#set -x
# Redirect output to a logfile, and save the original stdout so we can print
# messages
LOGFILE=${0%.*}.log
exec 6>&1 >$LOGFILE 2>&1

msg() {
    echo "$@" >&6
}

msgf() {
    printf "$@" >&6
}

TEST_COUNT=1
TEST_RESULTS=()
TEST_NAMES=()

# Comment out to disable color
COLOR=1

assert() {
    TEST_NAMES[TEST_COUNT]=$1
    echo "* assert $2"
    eval $2
    TEST_RESULTS[TEST_COUNT]=$?
    TEST_COUNT=$((TEST_COUNT + 1))
}

assert_ran_ok() {
    assert "$1" "[[ $? -eq 0 ]]"
}

assert_not_ran_ok() {
    assert "$1" "[[ $? -ne 0 ]]"
}


report() {
    [[ -n $COLOR ]] && {
        R=$(tput setaf 1)
        G=$(tput setaf 2)
        N=$(tput sgr0)
    }
    msg "===================================================================="
    msg "Test suite: $TEST_SUITE_NAME"
    msg "===================================================================="

    FAIL=0
    for ((i=1; $i < $TEST_COUNT; i++)); do
        NUMRESULT=${TEST_RESULTS[i]}
        RESULT="${G}PASS${N}"
        if [[ $NUMRESULT -gt 0 ]]; then
            RESULT="${R}FAIL${N}"
            FAIL=1
        fi
        msgf "%3s: %s - %s\n" "$i" "$RESULT" "${TEST_NAMES[i]}"
    done

    msg "===================================================================="

    TEST_COUNT=$((TEST_COUNT - 1))
    msg "Number of tests run: $TEST_COUNT"
    if [[ -n $TOTAL_TESTS ]]; then
        if [[ $TOTAL_TESTS -ne $TEST_COUNT ]]; then
            msg "${R}ERROR${N}: Expected to run $TOTAL_TESTS tests"
            FAIL=1
        fi
    fi

    exit $FAIL
}
