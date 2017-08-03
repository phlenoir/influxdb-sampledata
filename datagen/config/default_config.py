DEFAULT_CONFIG = {
    'generator': {
        'reconnect_wait_time_ms': 1000,
        'reader': 'reader.sim_reader',
    },
    'influxdb': {
        'host': 'localhost',
        'port': 8086,
        'user': 'admin',
        'password': 'admin',
        'dbname': 'trading',
        'use_ssl': False,
        'verify_ssl': False,
        'timeout': 5,
        'use_udp': False,
        'retention_policy': 'autogen',
        'time_precision': 's'
    },
    'encoder': 'encoder.echo_encoder',
    'buffer_size': 1000,
    'buffer_timeout': False,
    'configfile': None,
    'c': None,
    'statistics': True,
    's': False,
    'verbose': 0,
    'v': 0
}
