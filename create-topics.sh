#!/usr/bin/env bash
/opt/kafka_2.12-2.2.0/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --partitions 4 --replication-factor 1 --topic orders
/opt/kafka_2.12-2.2.0/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list
