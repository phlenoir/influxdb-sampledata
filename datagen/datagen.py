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
import csv
import os

UTCOFFSET = 0 #3600*2
USER = 'admin'
PASSWORD = 'admin'
DBNAME = 'trading'

'''
    Time series:
    - OE : order entry characterized by segment, partition, logical core, instrument

    Data:
    - 1000 instruments belonging to 2 partitions in the same segment
    - instrument number 0 to 499 are in the first partition
    - instrument number 500 to 999 are in the second partition
    - each partition has 2 logical cores
    - even numbers go to lc 1
    - odd numbers go to lc 2
'''
ip_address = {}
def load_samples(path):
    global ip_address
    for line in csv.reader(open(os.path.join(path, 'samples/ip_address.sample'), "rb")):
        if line[0][0] == "#":
            continue
        ip_address[line[0]] = line[1] if len(line) == 2 else line[1:]
    for k, v in ip_address.iteritems():
        print (k, v)

nano = 0
def get_time_ns():
    # always use UTC time with InfluxDB
    now = datetime.utcnow()
    # simulate latency (no time.perf_counter() in python 2)
    global nano
    nano += random.randint(1, 99999)
    #print("nano: %d" % nano)
    # UTCOFFSET not needed if target node is on zulu time
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
    #print(message)
    sent = sock.sendto(message.encode(encoding='utf_8', errors='strict'), server_address)

'''
Sample data: generate pseudo trading data with nano-second precision timestamps
  - 1 order entry generates n points of measure
  - the difference of two consecutive points measure a transit time
  - each transit time collection makes a time series

Goal
  - Automatically aggregate the nano-second resolution data
  - Automatically delete the raw, nano-second resolution data that are older than 1 hour
  - Automatically delete the 1-second resolution data that are older than 2 hours
'''
def main(host='localhost', port=8089, max_time=10, rate=1000, sampling=10):
    # we have 2 points of measure
    nb_points = 2
    sliced = max(100, int(rate / (sampling*nb_points)))

    # Create a UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_address = (host, port)

    # now we'll run for sometime, pushing data into influxdb
    start_time = time.time()  # remember when we started
    tags=dict()
    tags['segment'] = "EQU"
    ackpoints=dict()
    torpoints=dict()
    while (time.time() - start_time) < max_time:
        this_time = time.time()
        this_count = 0
        while 1:
            for i in range(0, sliced):
                tags['member'], tags['ip'] = random.choice(list(ip_address.items()))
                tags['oid'] = "order-%d" % uuid.uuid1()
                instid = random.randint(0, 999)
                tags['instrument'] = "instr-%d" % instid
                if instid < 500:
                    tags['partition'] = "p1"
                else:
                    tags['partition'] = "p2"
                if instid % 2 == 0:
                    tags['lc'] = "lc1"
                else:
                    tags['lc'] = "lc2"
                torpoints['tor_in'] = get_time_ns()
                ackpoints['oeg_in'] = get_time_ns()
                ackpoints['oeg_out'] = get_time_ns()
                ackpoints['me_in'] = get_time_ns()
                ackpoints['me_out'] = get_time_ns()
                ackpoints['ack_in'] = get_time_ns()
                ackpoints['ack_out'] = get_time_ns()
                torpoints['tor_out'] = get_time_ns()

                create_point("oeg.ack.sample", tags, ackpoints, server_address, sock)
                del tags['lc']
                tags['laid'] = "laid-{}-{}".format(tags['member'], tags['partition'])
                create_point("oeg.tor.sample", tags, torpoints, server_address, sock)
                del tags['laid']
                this_count +=2
            elapse = time.time() - this_time
            real_rate = this_count/elapse
            if (elapse < 1.0):
                if (this_count >= rate):
                    time.sleep(1.0-elapse)
                    print( "{} points in {}s (real rate = {} msg/s)".format( this_count, elapse, real_rate ) )
                    break
            else:
                print( "{} points in {}s (real rate = {} msg/s)".format( this_count, elapse, real_rate ) )
                break

        global nano
        nano = 0

    sock.close()

    print("End of data stream on %s" % sys.platform)

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
