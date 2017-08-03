#!/bin/bash
#set -x
export BASENAME=datagen
export BASEDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export pidfile=${BASEDIR}/${BASENAME}.pid

function log() {
    printf "%.23s %s[%s]: %s\n" $(date +%F.%T.%N) ${BASH_SOURCE[1]##*/} ${BASH_LINENO[0]} "${@}";
}

log "Stopping ${BASENAME} ..."
pid=`ps -elf|grep -v grep |grep ".*${BASENAME}.py" |awk '{print $4}'`
if [ ! "$pid" ]; then
    log "Didn't find any running ${BASENAME}"
    exit
fi

if ! kill $pid > /dev/null 2>&1; then
    log "Could not send SIGTERM to process $pid"
fi

MS=1000
while [[ 0 -ne $MS ]]; do
    if ! ps $pid > /dev/null ; then
        break
    fi
    sleep 0.1
    MS=$[$MS-100]
done
if ps $pid > /dev/null ; then
    log "Process $pid must be hard killed"
    kill -9 $pid > /dev/null 2>&1
fi
log "${BASENAME} stopped"
if [ -f $pidfile ]
then
    rm -f $pidfile
fi
