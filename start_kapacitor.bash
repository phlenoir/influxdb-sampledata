#!/bin/bash
export BASENAME=kapacitord
export BASEDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export LOGDIR=${BASEDIR}/kapacitor/var/log/kapacitor
export EXEDIR=${BASEDIR}/kapacitor/usr/bin
export CONFDIR=${BASEDIR}/kapacitor/etc/kapacitor
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
#exec onload ${EXEDIR}/kapacitord -config ${CONFDIR}/kapacitor.conf -pidfile ${pidfile} &
exec ${EXEDIR}/kapacitord -config ${CONFDIR}/kapacitor.conf -pidfile ${pidfile} &

