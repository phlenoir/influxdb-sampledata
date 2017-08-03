import logging
from encoder.escape_functions import influxdb_tag_escaper

class Encoder(object):
    """
    An encoder for the trading data generator
    """
    def __init__(self):
        self.escape_tag = influxdb_tag_escaper()

    def encode(self, measurements):
        return '\n'.join(measurements)
