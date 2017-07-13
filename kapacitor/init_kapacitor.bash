#!/usr/bin/bash

export KAPACITOR_ROOT=/app/influxdb/kapacitor-1.3.1-1
export KAPACITOR_BIN=${KAPACITOR_ROOT}/usr/bin/kapacitor
export KAPACITOR_OPT="-url http://qpdpecon24103-int:9092"

echo "define two_tasks_arithmetic task"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define two_tasks_arithmetic -tick ./tasks/two_tasks_arithmetic.tick -type stream -dbrp trading.rp_unit
echo "Kapacitor returned " $?

echo "enable two_tasks_arithmetic task"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable two_tasks_arithmetic
echo "Kapacitor returned " $?

echo "create template task"
${KAPACITOR_BIN} ${KAPACITOR_OPT} define-template generic_mean_latency -tick ./tasks/mean_latency_template.tick -type stream
echo "Kapacitor returned " $?

echo "define the task using the vars for the task"
# define the task using the vars for the task (-dbrp refers to the source rp)
${KAPACITOR_BIN} ${KAPACITOR_OPT} define mean_latency -template generic_mean_latency -vars ./tasks/latency_vars.json -dbrp trading.rp_unit
echo "Kapacitor returned " $?

echo "enable mean_latency task"
${KAPACITOR_BIN} ${KAPACITOR_OPT} enable mean_latency
echo "Kapacitor returned " $?
