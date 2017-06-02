'''
Created on 31 mai 2017

@author: Philippe
'''

from __future__ import print_function

import argparse
import random
import time

from influxdb import InfluxDBClient
from influxdb.client import InfluxDBClientError


USER = 'admin'
PASSWORD = 'admin'
DBNAME = 'tutorial'

from influxdb import SeriesHelper

class OptiqSeriesHelper(SeriesHelper):
    class Meta:
        series_name = 'trading_chain'
        fields = ['duration']
        tags = ['member_id', 'oeg_id', 'step']
        
def main(host='localhost', port=8086, nb_day=15):

    nb_day = 15  # number of day to generate time series
    timeinterval_min = 5  # create an event every x minutes
    total_minutes = 1440 * nb_day
    total_records = int(total_minutes / timeinterval_min)

    client = InfluxDBClient(host, port, USER, PASSWORD, DBNAME)

    print("Create database: " + DBNAME)
    try:
        client.create_database(DBNAME)
    except InfluxDBClientError:
        # Drop and create
        client.drop_database(DBNAME)
        client.create_database(DBNAME)

    print("Create a retention policy")
    retention_policy = 'server_data'
    client.create_retention_policy(retention_policy, '3d', 3, default=True)


    t0 = time.perf_counter()
    for i in range(0, total_records):
        elapse = time.time() + time.perf_counter() 
        tt=int(elapse * 1000000000)
        step='oeg_latency_in'
        duration=random.randint(12, 120)
        member_id = "member-%d" % random.randint(1, 5)
        oeg_id = "oeg-%d" % random.randint(1, 3)
        OptiqSeriesHelper(member_id=member_id, oeg_id=oeg_id, step=step, duration=duration, time=tt)
        print("Last point at: {0}".format(tt))
    
    OptiqSeriesHelper.commit(client)
    
    print("Write points #: {0}".format(total_records))


def parse_args():
    parser = argparse.ArgumentParser(
        description='example code to play with InfluxDB')
    parser.add_argument('--host', type=str, required=False, default='localhost',
                        help='hostname influxdb http API')
    parser.add_argument('--port', type=int, required=False, default=8086,
                        help='port influxdb http API')
    parser.add_argument('--nb_day', type=int, required=False, default=15,
                        help='number of days to generate time series data')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    main(host=args.host, port=args.port, nb_day=args.nb_day)