# -*- coding: utf-8 -*-
import logging
import uuid
import os
import random
import time
from datetime import datetime

from reader import ReaderAbstract

__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))

UTCOFFSET = 3600*2 # UTCOFFSET not needed if target node is on zulu time
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
    Time series:
    - order entry characterized by segment, partition, logical core, instrument
    - Member characterized by their id and ip
'''
class DatagenConsumer():
    def __init__(self, member_filename, instrument_filename):
        logging.info("Create a data generator with sampling from {} and{}".format(member_filename, instrument_filename))
        self.member = []
        self.instrument = []
        with open(member_filename, "rb") as f:
            for line in f:
                self.member.append(eval(line))
        with open(instrument_filename, "rb") as f:
            for line in f:
                self.instrument.append(eval(line))

    def close(self):
        logging.info("No more data: should never happen !")

    def __iter__(self):
        while True:
            message = self._get_message()
            if message:
                yield message

    def _get_message(self):
        tags=dict()
        ackpoints=dict()
        torpoints=dict()

        tags = random.choice(self.member)
        tags.update( random.choice(self.instrument) )
        tags['oid'] = "order-%d" % uuid.uuid1()
        torpoints['tor_in'] = get_time_ns()
        ackpoints['oeg_in'] = get_time_ns()
        ackpoints['oeg_out'] = get_time_ns()
        ackpoints['me_in'] = get_time_ns()
        ackpoints['me_out'] = get_time_ns()
        ackpoints['ack_in'] = get_time_ns()
        ackpoints['ack_out'] = get_time_ns()
        torpoints['tor_out'] = get_time_ns()

        ack = ''.join([
            str("oeg.ack-out.sample"),
            ',',
            ','.join('{}="{}"'.format(k, tags[k]) for k in tags),
            ' ',
            ','.join('{}={}i'.format(k, ackpoints[k]) for k in ackpoints),
            ' ',
            str(get_time_ns())
        ])

        tor = ''.join([
            str("oeg.tor-out.sample"),
            ',',
            ','.join('{}="{}"'.format(k, tags[k]) for k in tags),
            ' ',
            ','.join('{}={}i'.format(k, torpoints[k]) for k in torpoints),
            ' ',
            str(get_time_ns())
        ])

        return '\n'.join([ack, tor])


class Reader(ReaderAbstract):
    """
    A mock reader
    """
    def _connect(self):
        member_filename = os.path.join(__location__, '../samples/member.sample')
        instrument_filename = os.path.join(__location__, '../samples/instrument.sample')
        self.consumer = DatagenConsumer(member_filename=member_filename,
                                      instrument_filename=instrument_filename
                                      )

    def _handle_read(self):
        """
        Simulate read messages from somewhere.
        """
        for message in self.consumer:
            yield message
