'''
Created on 31 mai 2017

@author: Philippe
'''

from __future__ import print_function

import sys
import ast
import logging
from config import loader
from reader import load_reader
from writer import influxdb_writer
from encoder import load_encoder
from worker import Worker

__title__  = 'datagen'
__version__ = '0.0.1'

'''
Generate pseudo trading data with nano-second precision timestamps
  - 1 order entry generates 2 points of measure
  - the difference of two  points measure a transit time
  - each transit time collection makes a time series
'''
def start_emitter(config):
    """
    Start data emission
    """
    logging.debug("Initializing data simulator")
    reader = load_reader(config.generator_reader)

    logging.debug("Initializing connection to InfluxDB at %s:%s", config.influxdb_host, config.influxdb_port)
    writer = create_writer(config)

    logging.debug("Initializing message encoder: %s", config.encoder)
    encoder = load_encoder(config.encoder)

    client = Worker(reader, encoder, writer, config)
    client.consume()


def create_writer(config):
    """
    Create InfluxDB writer
    """
    return influxdb_writer.InfluxDBWriter(config.influxdb_host,
                                          config.influxdb_port,
                                          config.influxdb_user,
                                          config.influxdb_password,
                                          config.influxdb_dbname,
                                          config.influxdb_use_ssl,
                                          config.influxdb_verify_ssl,
                                          config.influxdb_timeout,
                                          config.influxdb_use_udp,
                                          config.influxdb_retention_policy,
                                          config.influxdb_time_precision)

def show_version():
    """
    Output current version and exit
    """
    print("{} {}".format(__title__, __version__))
    sys.exit(0)

if __name__ == '__main__':
    FORMAT = '%(asctime)-15s %(name)s:%(levelname)s:%(message)s'
    logging.basicConfig(format=FORMAT)
    config = loader.load_config()
    if config.version:
        show_version()

    start_emitter(config)
