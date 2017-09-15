#!/bin/bash
#set -x
export BASENAME=influxd
export BASEDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export LOGDIR=${BASEDIR}/influxdb/var/log/influxdb
export EXEDIR=${BASEDIR}/influxdb/usr/bin
export CONFDIR=${BASEDIR}/influxdb/etc/influxdb
export pidfile=${BASEDIR}/${BASENAME}.pid

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
exec ${EXEDIR}/influxd run -config ${CONFDIR}/influxdb.conf -pidfile ${pidfile} 2>${LOGDIR}/influxdb.log &
