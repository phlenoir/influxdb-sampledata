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
import sys
import os
import ast

UTCOFFSET = 3600*2 # UTCOFFSET not needed if target node is on zulu time
USER = 'admin'
PASSWORD = 'admin'
DBNAME = 'trading'

'''
    Time series:
    - order entry characterized by segment, partition, logical core, instrument
    - Member characterized by their id and ip
'''
member = []
instrument = []
def load_samples(path):
    global member
    with open(os.path.join(path, 'samples/member.sample'), "rb") as f:
        for line in f:
            member.append(eval(line))

    global instrument
    with open(os.path.join(path, 'samples/instrument.sample'), "rb") as f:
        for line in f:
            instrument.append(eval(line))


nano = 0
def get_time_ns():
    # always use UTC time with InfluxDB
    now = datetime.utcnow()
    # simulate latency (no time.perf_counter() in python 2)
    global nano
    nano += random.randint(1, 99999)
    #print("nano: %d" % nano)
    elapse = time.mktime(now.timetuple()) + UTCOFFSET + now.microsecond / 1E6
    return int(elapse * 1E9 + nano)

'''
    Create a point in 'measurement' time series with a list of tags and values
    All values are timestamps created by get_time_ns()
'''
def create_point(measurement, tags, values, server_address, sock):
    # use InfluxDB line protocol
    # see https://docs.influxdata.com/influxdb/v1.2/write_protocols/line_protocol_reference/#data-types
    message='%s' % measurement
    for key, val in tags.items():
        message+=',{}="{}"'.format(key, val)
    sep = ' '
    for key, val in values.items():
        message+='{}{}={}i'.format(sep, key, val)
        sep = ','
    tt = get_time_ns()
    message+=' %d' % tt
    sent = sock.sendto(message.encode(encoding='utf_8', errors='strict'), server_address)
    #print("Sent {} bytes: {}".format(sent, message))

'''
Sample data: generate pseudo trading data with nano-second precision timestamps
  - 1 order entry generates n points of measure
  - the difference of two  points measure a transit time
  - each transit time collection makes a time series
'''
def main(host='localhost', port=8089, max_time=10, rate=1000, sampling=10):

    slice_time = 1/sampling
    slice_points = rate/sampling
    # total points sent
    total_points = 0

    # Create a UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_address = (host, port)

    # now we'll run for sometime, pushing data into influxdb
    start_time = time.time()  # remember when we started
    tags=dict()
    ackpoints=dict()
    torpoints=dict()
    while (time.time() - start_time) < max_time:
        this_time = time.time()
        period_count = 0
        while 1:
            # no less than 1000 points between time checks
            for i in range(0, 1000):
                tags = random.choice(member)
                tags.update( random.choice(instrument) )
                tags['oid'] = "order-%d" % uuid.uuid1()

                torpoints['tor_in'] = get_time_ns()
                ackpoints['oeg_in'] = get_time_ns()
                ackpoints['oeg_out'] = get_time_ns()
                ackpoints['me_in'] = get_time_ns()
                ackpoints['me_out'] = get_time_ns()
                ackpoints['ack_in'] = get_time_ns()
                ackpoints['ack_out'] = get_time_ns()
                torpoints['tor_out'] = get_time_ns()

                create_point("oeg.ack-out.sample", tags, ackpoints, server_address, sock)
                create_point("oeg.tor-out.sample", tags, torpoints, server_address, sock)
                total_points +=1
                period_count +=1
            elapse = time.time() - this_time
            if (elapse >= slice_time) :
                break
            if ( period_count >= slice_points ) :
                time.sleep(slice_time - elapse)
                break
        # reset the nano counter
        global nano
        nano = 0

    sock.close()

    print( "End of data stream on %s" % sys.platform)
    elapse = time.time() - start_time
    print( "{} points written per series in {}s ({} msg/s)".format( total_points, elapse, total_points/elapse ) )

def parse_args():
    parser = argparse.ArgumentParser(
        description='example code to play with InfluxDB')
    parser.add_argument('--host', type=str, required=False, default='localhost',
                        help='hostname influxdb http API')
    parser.add_argument('--port', type=int, required=False, default=8089,
                        help='port influxdb http API')
    parser.add_argument('--sec', type=int, required=False, default=3,
                        help='amount of seconds we will be pushing data to influxdb')
    parser.add_argument('--rate', type=int, required=False, default=1000,
                    help='number of messages per second to send to influxdb')
    parser.add_argument('--sampling', type=int, required=False, default=10,
                    help='number of times per second the rate is checked')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
    load_samples(__location__)
    main(host=args.host, port=args.port, max_time=args.sec, rate=args.rate, sampling=args.sampling)
