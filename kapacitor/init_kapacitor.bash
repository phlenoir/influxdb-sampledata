#!/usr/bin/bash

# define and enable join task
kapacitor define two_tasks_arithmetic -tick ./tasks/two_tasks_arithmetic.tick -type stream -dbrp trading.rp_unit
kapacitor enable two_tasks_arithmetic

# create template task
kapacitor define-template generic_mean_latency -tick ./tasks/mean_latency_template.tick -type stream
# define the task using the vars for the task (-dbrp refers to the source rp)
kapacitor define mean_latency -template generic_mean_latency -vars ./tasks/latency_vars.json -dbrp trading.rp_unit
kapacitor enable mean_latency

