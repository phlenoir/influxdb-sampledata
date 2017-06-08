'''
Created on 31 mai 2017

@author: Philippe
'''

from __future__ import print_function

import argparse
import random
import time
from datetime import datetime

from influxdb import InfluxDBClient
from influxdb.client import InfluxDBClientError

UTCOFFSET = 3600*2
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

mtypes = {"latency" : 'latency' ,
          "elapse"  : 'elapse' }


class TCSeriesHelper(SeriesHelper):
    class Meta:
        series_name = 'tc'
        fields = ['duration']
        tags = [ 'mname', 'mid', 'mway', 'mtype' ]
        
def get_time_ns():
    # always use UTC time with InfluxDB
    now = datetime.utcnow() 
    elapse = time.mktime(now.timetuple()) + UTCOFFSET + now.microsecond / 1E6 + time.perf_counter() 
    return int(elapse * 1000000000)

def create_point(m_name, m_id, m_way, m_type, value):
    tt =  get_time_ns()
    TCSeriesHelper(mname=m_name, mid=m_id, mway=m_way, mtype=m_type, duration=value, time=tt)

    
'''
Sample data: generate pseudo trading data with nano-second precision
  - 1 order entry generates 10 metrics messages
  - commit every 5000 points (i.e. every 500 order entries)
  
  
Goal
  - Automatically aggregate the nano-second resolution data 
  - Automatically delete the raw, nano-second resolution data that are older than 1 hour
  - Automatically delete the 1-second resolution data that are older than 2 hours
'''
def main(host='localhost', port=8086, max_time=10):

    nb_points_per_oe = 10  # number of points per order entry
    bulk_commit = 5000  # number of insert before committing 
    total_records = int(bulk_commit / nb_points_per_oe)

    client = InfluxDBClient(host, port, USER, PASSWORD, DBNAME)

    print("Create database: " + DBNAME)
    try:
        client.create_database(DBNAME)
    except InfluxDBClientError:
        print("Dropping old database first")
        client.drop_database(DBNAME)
        client.create_database(DBNAME)

    print("Create a 1d default retention policy for unit values")
    rp = 'rp_unit'
    try:
        client.create_retention_policy(rp, '1d', 1, default=True)
    except InfluxDBClientError:
        print("Dropping old RP first")
        client.query('DROP RETENTION POLICY {0} on {1}'.format(rp, DBNAME))
        client.create_retention_policy(rp, '1d', 1, default=True)
        
    print("Create a 2d retention policy for aggregated values")
    rp = 'rp_agg'
    try:
        client.create_retention_policy(rp, '2d', 1, default=False)
    except InfluxDBClientError:
        print("Dropping old RP first")
        client.query('DROP RETENTION POLICY {0} on {1}'.format(rp, DBNAME))
        client.create_retention_policy(rp, '2d', 1, default=False)
       
    print("Create a continuous query")
    query_string = 'CREATE CONTINUOUS QUERY "member_latency_in_1s" ON {0} BEGIN '\
                   'SELECT mean("duration") AS "mean_member_latency_in" '\
                   'INTO rp_agg.member_agg_1s '\
                   'FROM "tc" '\
                   'WHERE mtype={1} '\
                   'AND mname={2} '\
                   'AND mway={3} '\
                   'GROUP BY time(1s), "mid" '\
                   'END'.format( DBNAME, "'latency'", "'member'", "'in'") 
    try:
        client.query(query_string)
    except InfluxDBClientError:
        print("Dropping old CQ first")
        client.query('DROP CONTINUOUS QUERY member_latency_in_1s on {0}'.format(DBNAME))
        client.query(query_string)
        
    # now we'll run for sometime, pushing data into influxdb
    start_time = time.time()  # remember when we started
    while (time.time() - start_time) < max_time:
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
    parser.add_argument('--sec', type=int, required=False, default=300,
                        help='amount of seconds we will be pushing data to influxdb')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    main(host=args.host, port=args.port, max_time=args.sec)