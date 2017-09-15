#!/bin/bash
#set -x
export BASENAME=telegraf
export BASEDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export LOGDIR=${BASEDIR}/telegraf/var/log/telegraf
export EXEDIR=${BASEDIR}/telegraf/usr/bin
export CONFDIR=${BASEDIR}/telegraf/etc/telegraf
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
exec ${EXEDIR}/telegraf --config ${CONFDIR}/telegraf.conf -pidfile ${pidfile} 2>${LOGDIR}/telegraf.log &
