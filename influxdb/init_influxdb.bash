#!/usr/bin/bash
DBURL=172.26.160.10:8086
DBNAME=trading

# create dabase
curl -i -XPOST http://$DBURL/query --data-urlencode "q=CREATE DATABASE trading"

# create retention policies
curl -i -XPOST http://$DBURL/query --data-urlencode "q=DROP RETENTION POLICY \"rp_unit\" ON \"trading\""
curl -i -XPOST http://$DBURL/query --data-urlencode "q=CREATE RETENTION POLICY \"rp_unit\" ON \"trading\" DURATION 2d REPLICATION 1 DEFAULT"
curl -i -XPOST http://$DBURL/query --data-urlencode "q=DROP RETENTION POLICY \"rp_agg\" ON \"trading\""
curl -i -XPOST http://$DBURL/query --data-urlencode "q=CREATE RETENTION POLICY \"rp_agg\" ON \"trading\" DURATION 1d REPLICATION 1"
