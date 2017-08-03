#!/bin/bash
#set -x
export BASENAME=datagen
export BASEDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export pidfile=${BASEDIR}/${BASENAME}.pid
export PYTHONPATH=${BASEDIR}/pythonlib/site-packages/
if [ -z ${DATAGEN+x} ]
then
    export DATAGEN="python ${BASEDIR}/datagen/datagen.py"
fi

function log() {
    printf "%.23s %s[%s]: %s\n" $(date +%F.%T.%N) ${BASH_SOURCE[1]##*/} ${BASH_LINENO[0]} "${@}";
}

log "Starting ${BASENAME} ..."
if [ -f $pidfile ]
then
    pid=`cat $pidfile`
    if ps $pid > /dev/null
    then
        log "${BASENAME} already started"
        exit 1
    fi
    # pid file is out-of-date
    rm "$pidfile"
fi
exec ${DATAGEN} "$@" &
