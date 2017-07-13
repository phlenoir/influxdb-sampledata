import sys
import os

'''
    Member sample data
    - 50 members with their own ip address
'''
def ip_sample(path):
    with open(os.path.join(path, 'member.sample'), 'wt') as f:
        for id in range(50):
            line = "{'member' : 'member-%02d','ip' : '10.11.36.%d'}" % (id, id)
            f.write(line + os.linesep)

'''
    Instrument sample data:
    - 1000 instruments belonging to 2 partitions in the same segment
    - instrument number 0 to 499 are in the first partition
    - instrument number 500 to 999 are in the second partition
    - each partition has 2 logical cores
    - even numbers go to lc 1
    - odd numbers go to lc 2
'''
def instrument_sample(path):
    with open(os.path.join(path, 'instrument.sample'), 'wt') as f:
        for instid in range(1000):
            line = "{'instrument' : 'instr-%04d'" % instid
            if instid < 500:
                line += ", 'partition' : 'p1'"
            else:
                line += ", 'partition' : 'p2'"
            if instid % 2 == 0:
                line += ", 'lc' : 'lc1'"
            else:
                line += ", 'lc' : 'lc2'"
            line += ", 'segment' : 'EQU'}"
            f.write(line + os.linesep)

if __name__ == '__main__':
    __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
    ip_sample(__location__)
    instrument_sample(__location__)
