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
DBNAME = 'trading'

from influxdb import SeriesHelper

modules = {"member"  : "member",
           "oeg"     : "oeg",
           "me"      : "me",
           "me_book" : "me_book",
           "me_mdb"  : "me_mdb",
           "mdp"     : "mdp" }

mways = {"in"  : "in",
         "out" : "out" }

mtypes = {"latency" : "latency" ,
          "elapse"  : "elapse" }


class TCSeriesHelper(SeriesHelper):
    class Meta:
        series_name = 'tc'
        fields = ['duration']
        tags = [ 'mname', 'mid', 'mway', 'mtype' ]
        
def get_time_ns():
    elapse = time.time() + time.perf_counter() 
    return int(elapse * 1000000000)

def create_point(m_name, m_id, m_way, m_type, value):
    tt =  get_time_ns()
    TCSeriesHelper(mname=m_name, mid=m_id, mway=m_way, mtype=m_type, duration=value, time=tt)
    
def main(host='localhost', port=8086, nb_day=15):

    nb_points_per_oe = 10  # number of points per order entry
    bulk_commit = 5000  # number of insert before committing 
    total_records = int(bulk_commit / nb_points_per_oe)

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

    for i in range(0, total_records):
        
        duration=random.randint(12, 120)
        member_id = "member-%d" % random.randint(1, 50)
        segment = random.randint(1, 3)
        oeg_id = "oeg-%d" % segment
        me_id = "me-%d" % segment
        mdp_id = "mdp-%d" % random.randint(1, 5)
        
        create_point(modules['member'], member_id, mways['in'], mtypes['latency'], duration)
        
        duration=random.randint(12, 120)
        create_point(modules['oeg'], oeg_id, mways['in'], mtypes['elapse'], duration)
        
        duration=random.randint(12, 120)
        create_point(modules['me'], me_id, mways['in'], mtypes['latency'], duration)
        
        duration=random.randint(12, 120)
        create_point(modules['me_book'], me_id, mways['in'], mtypes['elapse'], duration)
        
        duration=random.randint(12, 120)
        create_point(modules['me_mdb'], me_id, mways['in'], mtypes['latency'], duration)
        
        duration=random.randint(12, 120)
        create_point(modules['me_mdb'], me_id, mways['in'], mtypes['elapse'], duration)
        
        duration=random.randint(12, 120)
        create_point(modules['mdp'], mdp_id, mways['in'], mtypes['latency'], duration)
        
        duration=random.randint(12, 120)
        create_point(modules['mdp'], mdp_id, mways['in'], mtypes['elapse'], duration)
        
        duration=random.randint(12, 120)
        create_point(modules['oeg'], oeg_id, mways['out'], mtypes['latency'], duration)
        
        duration=random.randint(12, 120)
        create_point(modules['oeg'], oeg_id, mways['out'], mtypes['elapse'], duration)
    
    TCSeriesHelper.commit(client)
    
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