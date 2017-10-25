#!/bin/bash
export BASEDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Use onload to bypass the Kernel
#export DATAGEN="onload python ${BASEDIR}/datagen/datagen.py"
export DATAGEN="python ${BASEDIR}/datagen/datagen.py"
export STARTGEN="${BASEDIR}/start_gen.bash"
export STOPGEN="${BASEDIR}/stop_gen.bash"
export INFLUXSTRESS="${BASEDIR}/influx-stress"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${BASEDIR}/pcap2inf
export PCAP2INF="${BASEDIR}/pcap2inf/pcap2inf"
export MDG2INDB="${BASEDIR}/pcap2inf/mdg2indb"

# Don't use dnsname in python script or the DNS server will be pinged for EVERY request sent
export INFLUXDB_HOSTIP=172.26.160.10
export KAPACITOR_HOSTIP=172.26.160.11

# handle multiple instances of InfluxDB and/or Kapacitor
export INFLUXDB_URLS=("http://qpdpecon24102-int:8086" "http://qpdpecon24103-int:8086")
export KAPACITOR_URLS=("http://qpdpecon24102-int:9092" "http://qpdpecon24103-int:9092")
export KAPACITOR_URL="http://qpdpecon24101-int:9092"

# TODO make http REST requets instead of binary call
export KAPACITOR_ROOT=${BASEDIR}/kapacitor
export KAPACITOR_BIN=${KAPACITOR_ROOT}/usr/bin/kapacitor
export KAPACITOR_OPT="-url ${KAPACITOR_URL}"
export KAPACITOR_TICKDIR=${BASEDIR}/tasks

export INFLUXCLI_BIN=${BASEDIR}/influxdb/usr/bin/influx

# point to locally installed python modules
export PYTHONPATH=${BASEDIR}/pythonlib/site-packages/:${PYTHONPATH}
