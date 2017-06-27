'''
Created on 31 mai 2017

@author: Philippe
'''

from __future__ import print_function

import argparse
import random
import time
from datetime import datetime
import uuid
import socket
import monotonic

UTCOFFSET = 3600*2
USER = 'admin'
PASSWORD = 'admin'
DBNAME = 'trading'

'''
    Time series:
    - OE : order entry characterized by segment, partition, logical core, instrument
           Because overall tag number matters, we limit cardinality by not including order id in the tag list
           
    Data:
    - 1000 instruments belonging to 2 partitions in the same segment
    - instrument number 0 to 499 are in the first partition
    - instrument number 500 to 999 are in the second partition
    - each partition has 2 logical cores
    - even numbers go to lc 1
    - odd numbers go to lc 2
'''
        
def get_time_ns():
    # always use UTC time with InfluxDB
    now = datetime.utcnow() 
    elapse = time.mktime(now.timetuple()) + UTCOFFSET + now.microsecond / 1E6 + monotonic.monotonic()
    return int(elapse * 1000000000)

def create_point(measurement, membid, oid, segid, instid, server_address, sock):
    
    tstamp = get_time_ns()
    
    instrid = "instr-%d" % instid
    if instid < 500:
        partid = "p1"
    else:
        partid = "p2"
    if instid % 2 == 0:
        lcid = "%s-lc1" % partid
    else:
        lcid = "%s-lc2" % partid
        
    tt = get_time_ns()
    latency = tt - tstamp
    
    # use InfluxDB line protocol
    # see https://docs.influxdata.com/influxdb/v1.2/write_protocols/line_protocol_reference/#data-types
    message = '%s,member="%s",segment="%s",partition="%s",lc="%s",instrument="%s",oid="%s" value=%di %d' % (measurement, membid, segid, partid, lcid, instrid, oid, tt, tt)
    #print(message)
    sent = sock.sendto(message.encode(encoding='utf_8', errors='strict'), server_address)
    
'''
Sample data: generate pseudo trading data with nano-second precision
  - 1 order entry generates n points of measure
  - the difference of two consecutive points measure a transit time
  - each transit time collection makes a time series
  - commit every 5000 points (i.e. every 500 order entries)
  
Goal
  - Automatically aggregate the nano-second resolution data 
  - Automatically delete the raw, nano-second resolution data that are older than 1 hour
  - Automatically delete the 1-second resolution data that are older than 2 hours
'''
def main(host='localhost', port=8086, max_time=10):

    nb_points_per_oe = 2  # number of points per order entry
    bulk_commit = 1000  # number of insert before committing 
    total_records = int(bulk_commit / nb_points_per_oe)
    
    # Create a UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_address = ('localhost', 9100)

    # now we'll run for sometime, pushing data into influxdb
    start_time = time.time()  # remember when we started
    while (time.time() - start_time) < max_time:
        for i in range(0, total_records):
            membid = "member-%d" % random.randint(1, 10)
            oid = "order-%d" % uuid.uuid1()
            segid="PAR"
            instid = random.randint(0, 999)
            create_point("oeg.order-in.sample", membid, oid, segid, instid, server_address, sock)
            create_point("oeg.order-out.sample", membid, oid, segid, instid, server_address, sock)
 
        print("Write points #: {0}".format(total_records))
        time.sleep(0.1)
        
    sock.close()
       
    print("End of data stream")

def parse_args():
    parser = argparse.ArgumentParser(
        description='example code to play with InfluxDB')
    parser.add_argument('--host', type=str, required=False, default='localhost',
                        help='hostname influxdb http API')
    parser.add_argument('--port', type=int, required=False, default=8086,
                        help='port influxdb http API')
    parser.add_argument('--sec', type=int, required=False, default=30,
                        help='amount of seconds we will be pushing data to influxdb')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    main(host=args.host, port=args.port, max_time=args.sec)
