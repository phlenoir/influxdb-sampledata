# influxdb-sampledata
Simple testing framework that generates sample data into an Influxdb database

The data generator produces 2 simultaneous series of data using sample data from the datagen/samples directory
* member.sample : a dictionary of members and their ip address
* instrument.sample : a dicitonary of instruments and theirs charactiristics

Use the provided `datagen/samples/samples.py` script to generate those dictionaries

Configuration is made by overwritting default parameters from `datagen/config/default_config.py` using command line parameters or a YAML file.
Use `start_gen.bash --help` to list all available options.

## Basic commands
* `01-something-test.sh` will run one test script individually
* `test.sh` a helper menu to pick-up test scripts to run
* `test_setup.sh` contains variables that should be adjusted to the environment
* `clean.sh` will remove any `.log` and `.out` files generated during tests
* `start_gen.bash` will start generating data for ever
* `stop_gen.bash` stops the data generator

## Testing environment
All variables relative to the testing environment are set in `test_setup.sh`.
A test is defined by its number, a short description and a -test.sh suffix. So any file in the form `nn-<description>-test.sh` defines a test that is callable from the test.sh utility. Every test is associated with a corresponding YAML file that defines specific test variables, e.g. `nn-<description>-test.yaml`. The YAML file must be present, even if it is empty. If some test outputs need to be compared to pre-defined values to validate the test, put the expected test output in a corresponding file with the cmp extension, e.g. `nn-<description>-test.cmp`

There are a number of predefined tests easily accessible with the `test.sh`  helper menu.
* test #01 to ping InfluxDB server
* test #02 to create database, retention policies, etc.
* test #03 to check Kapacitor is running
* test #04 to check Kapacitor tasks syntax
* test #05 #06 ... performance tests

## Details about performance tests
### Test #05
Two streams of data are sent to InfluxDB which automatically inserts points in the DB.
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

### Test #06
Two streams of data are sent to the Kapacitor UDP end-point. A Kapacitor task capture one of them and sends it to InfluxDB. See task defined in `tasks/simplest.tick`

### Test #07
Two streams of data are sent to the Kapacitor UDP end-point. A Kapacitor task
task captures these two streams and join them together to produce an Influxdb measurement of the latency (i.e. the diff between the 2 timestamps). See task defined in `tasks/two_tasks_arithmetic.tick`

### Test #08
Computes a latency from two streams of data like in test #07 and aggregates the result to produce the mean of the latency per 1-second bucket. This measurement is then stored to InfluxDB.

### Test #09
Like test #08 but operates on 4 latencies instead of one and run for two hours to follow ressource consumption, see capture below:

![Test 09 screen](/images/09-perf-kapacitor-all-latencies-test.png)

## Data producer
Performance tests make use of the `datagen/datagen.py` python script to generate streams of data using the InfluxDB line protocol, understood by Kapacitor as well. Run `python datagen/datagen.py -h` to see helpful information about this script.

Use `datagen/samples/samples.py` script to generate random data to be used in the time series generator.
* member.sample a list of 50 member IDs with their respective IP address
* instrument.sample a list of 1000 instruments. Instruments with id between 1 and 499 belong to partition #1, other instruments with id between 500 and 999 belong to partition #2. Instruments with odd id number belong to the first logical core of their partition, other instruments with even id number belong to the second logical core.

Each characteristic, like ip address in the member sample set, will be used as a tag in the generated time series. All values are made of timestamps simulating an ACK message that contains time of passed check points along the route taken by an order message from OEG to ME and back. The list of tags/characteristics is dynamic and the data generator will adapt the messages sent to InfluxDB/Kapacitor accordingly, but if you change the dictionaries the TICK scripts may not work anymore.

## Tips
List all Kapacitor tasks
```
/app/influxdb/kapacitor-1.3.1-1/usr/bin/kapacitor -url "http://qpdpecon24103-int:9092" list tasks
```
Delete a task
```
/app/influxdb/kapacitor-1.3.1-1/usr/bin/kapacitor -url "http://qpdpecon24103-int:9092" detete tasks [my_task]
```
## Dependencies
You may use pip to install those dependencies :
* influxdb
* pyyaml

If you do not have root access you can put your python libs anywhere and adjust your PYTHONPATH in `test_setup.sh`

You must have InfluxDB and Kapacitor up and running, listening to the appropriate ports used by the tests.

Note that most of the tests use the Kapacitor binaries to communicate with the Kapacitor server and so they must be locally accessible. InfluxDB commands are passed through http/REST protocol and need curl.  

I recommend you to use Grafana + influxdb-internals dashboard (available on Grafana download site) to follow InfluxDB activity while running the tests.

## Tributes
* The testing framework was largely inspired by https://github.com/mivok/bash_test
* The python data generator was adapted from https://github.com/mre/kafka-influxdb where the Kafka reader has been replaced by a simulator of incomming messages
