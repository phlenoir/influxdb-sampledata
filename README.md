# influxdb-sampledata
Simple testing framework Generate sample data into an Influxdb dabase

## Basics
* `all_tests.sh` will go through each test in turn
* `01-something-test.sh` will run one test script individually
* `test.sh` a helper menu to pick-up test scripts to run
* `test_setup.sh` contains variables that should be adjusted to the environment
* `clean.sh` will remove any `.log` and `.out` files generated during tests

## Initialize the testing environment
* Install Influxdb, use test #01 to check installation
* Initialize InfluxDB with test #02 to create database, retention policies, etc.
* Install Kapacitor, use test #03 to check installation
* Initialize Kapacitor tasks with test #03
* run samples.py to generate sample data files for members and instruments
* Run any of the performance test (tests #05 #06 etc.)

## Details about performance tests
### Test #05
Two streams of data are sent to the InfluxDB UDP end-point which automatically insert points in the DB.
```
InfluxDB shell version: 1.2.4
> use trading
Using database trading
> show measurements
name: measurements
name
----
oeg.ack-out.sample
oeg.tor-out.sample
```

### Tets #06
Two streams of data are sent to the Kapacitor UDP end-point. A first Kapacitor task will capture these two streams and join them together to produce an Influxdb measurement of the latency (i.e. the diff between the 2 timestamps). A second Kapacitor task is streaming the InfluxDB measurement to compute the mean of the latency per 1-second bucket.

## Data producer
Performance tests make use of the `datagen/datagen.py` python script to generate streams of data using the InfluxDB line protocol, understood by Kapacitor. Run `python datagen/datagen.py -h` to see helpful information about this script.

Use `datagen/samples/samples.py` script to generate random data to be used in the time series generator.
* member.sample a list of 50 member IDs with their respective IP address
* instrument.sample a list of 1000 instruments

## Tips
List all Kapacitor tasks
```
/app/influxdb/kapacitor-1.3.1-1/usr/bin/kapacitor -url "http://qpdpecon24103-int:9092" list tasks
```
Delete a task
```
/app/influxdb/kapacitor-1.3.1-1/usr/bin/kapacitor -url "http://qpdpecon24103-int:9092" detete tasks [my_task]
```

## Tributes
The testing framework was largely inspired by https://github.com/mivok/bash_test
