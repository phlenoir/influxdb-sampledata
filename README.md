# influxdb-sampledata
Generate sample data into an Influxdb dabase

## Initialize the tool set
run './influxdb/init_influxdb.bash' to create the data base and the retention policies
run './kapacitor/init_kapacitor.bash' to create 2 Kapacitor tasks

The first task will listen on UDP port 9100 to capture 2 streams of messages containing timestamps. The 2 streams are joined together to produce an Influxdb measurement of the latency (i.e. the diff between the 2 timestamps).

The second task is a stream task working on the InfluxDB measurement to compute the mean of the latency per 1-second bucket.

## Simulate data producer
Use the datagen.py script to generate a stream of data on UDP port 9100 using the InfluxDB line protocol, understood by Kapacitor.
run 'python datagen/datagen.py'

By default the script will run for 30s with a 0.1 second pause every 500 messages.
