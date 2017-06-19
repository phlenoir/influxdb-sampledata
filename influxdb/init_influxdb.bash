#!/usr/bin/bash
DBURL=localhost:8086
DBNAME=trading

# create dabase
curl -i -XPOST http://$DBURL/query --data-urlencode "q=CREATE DATABASE trading"

# create retention policies
curl -i -XPOST http://$DBURL/query --data-urlencode "q=CREATE RETENTION POLICY \"rp_unit\" ON \"trading\" DURATION 1h REPLICATION 1 DEFAULT"
curl -i -XPOST http://$DBURL/query --data-urlencode "q=CREATE RETENTION POLICY \"rp_agg\" ON \"trading\" DURATION 2h REPLICATION 1"

