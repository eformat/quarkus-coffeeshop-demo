#!/bin/bash

createEphemeralCluster() {
oc apply -n strimzi -f- <<EOF
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
  namespace: strimzi
spec:
  kafka:
    version: 2.2.1
    replicas: 3
    listeners:
      plain: {}
      tls: {}
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      log.message.format.version: '2.2'
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}
EOF
}

createStatefulCluster() {
oc apply -n strimzi -f- <<'EOF'
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-cluster
  namespace: strimzi
spec:
  kafka:
    version: 2.2.1
    replicas: 3
    resources:
      requests:
        memory: 2Gi
        cpu: 500m
      limits:
        memory: 2Gi
        cpu: "1"
    jvmOptions:
      -Xms: 1024m
      -Xmx: 1024m
    listeners:
      plain: {}
      tls: {}
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
    storage:
      type: persistent-claim
      size: 5Gi
      deleteClaim: false
    metrics:
      # Inspired by config from Kafka 2.0.0 example rules:
      # https://github.com/prometheus/jmx_exporter/blob/master/example_configs/kafka-2_0_0.yml
      lowercaseOutputName: true
      rules:
        # Special cases and very specific rules
        - pattern : kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value
          name: kafka_server_$1_$2
          type: GAUGE
          labels:
            clientId: "$3"
            topic: "$4"
            partition: "$5"
        - pattern : kafka.server<type=(.+), name=(.+), clientId=(.+), brokerHost=(.+), brokerPort=(.+)><>Value
          name: kafka_server_$1_$2
          type: GAUGE
          labels:
            clientId: "$3"
            broker: "$4:$5"
        # Some percent metrics use MeanRate attribute
        # Ex) kafka.server<type=(KafkaRequestHandlerPool), name=(RequestHandlerAvgIdlePercent)><>MeanRate
        - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>MeanRate
          name: kafka_$1_$2_$3_percent
          type: GAUGE
        # Generic gauges for percents
        - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>Value
          name: kafka_$1_$2_$3_percent
          type: GAUGE
        - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*, (.+)=(.+)><>Value
          name: kafka_$1_$2_$3_percent
          type: GAUGE
          labels:
            "$4": "$5"
        # Generic per-second counters with 0-2 key/value pairs
        - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+), (.+)=(.+)><>Count
          name: kafka_$1_$2_$3_total
          type: COUNTER
          labels:
            "$4": "$5"
            "$6": "$7"
        - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+)><>Count
          name: kafka_$1_$2_$3_total
          type: COUNTER
          labels:
            "$4": "$5"
        - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*><>Count
          name: kafka_$1_$2_$3_total
          type: COUNTER
        # Generic gauges with 0-2 key/value pairs
        - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Value
          name: kafka_$1_$2_$3
          type: GAUGE
          labels:
            "$4": "$5"
            "$6": "$7"
        - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Value
          name: kafka_$1_$2_$3
          type: GAUGE
          labels:
            "$4": "$5"
        - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Value
          name: kafka_$1_$2_$3
          type: GAUGE
        # Emulate Prometheus 'Summary' metrics for the exported 'Histogram's.
        # Note that these are missing the '_sum' metric!
        - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Count
          name: kafka_$1_$2_$3_count
          type: COUNTER
          labels:
            "$4": "$5"
            "$6": "$7"
        - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*), (.+)=(.+)><>(\d+)thPercentile
          name: kafka_$1_$2_$3
          type: GAUGE
          labels:
            "$4": "$5"
            "$6": "$7"
            quantile: "0.$8"
        - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Count
          name: kafka_$1_$2_$3_count
          type: COUNTER
          labels:
            "$4": "$5"
        - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*)><>(\d+)thPercentile
          name: kafka_$1_$2_$3
          type: GAUGE
          labels:
            "$4": "$5"
            quantile: "0.$6"
        - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Count
          name: kafka_$1_$2_$3_count
          type: COUNTER
        - pattern: kafka.(\w+)<type=(.+), name=(.+)><>(\d+)thPercentile
          name: kafka_$1_$2_$3
          type: GAUGE
          labels:
            quantile: "0.$4"
  zookeeper:
    replicas: 3
    resources:
      requests:
        memory: 1Gi
        cpu: "0.3"
      limits:
        memory: 1Gi
        cpu: "0.5"
    jvmOptions:
      -Xms: 512m
      -Xmx: 512m
    storage:
      type: persistent-claim
      size: 5Gi
      deleteClaim: false
    metrics:
      # Inspired by Zookeeper rules
      # https://github.com/prometheus/jmx_exporter/blob/master/example_configs/zookeeper.yaml
      lowercaseOutputName: true
      rules:
        # replicated Zookeeper
        - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+)><>(\\w+)"
          name: "zookeeper_$2"
        - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+)><>(\\w+)"
          name: "zookeeper_$3"
          labels:
            replicaId: "$2"
        - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+)><>(\\w+)"
          name: "zookeeper_$4"
          labels:
            replicaId: "$2"
            memberType: "$3"
        - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+), name3=(\\w+)><>(\\w+)"
          name: "zookeeper_$4_$5"
          labels:
            replicaId: "$2"
            memberType: "$3"
        # standalone Zookeeper
        - pattern: "org.apache.ZooKeeperService<name0=StandaloneServer_port(\\d+)><>(\\w+)"
          name: "zookeeper_$2"
        - pattern: "org.apache.ZooKeeperService<name0=StandaloneServer_port(\\d+), name1=(InMemoryDataTree)><>(\\w+)"
          name: "zookeeper_$2_$3"
  entityOperator:
    topicOperator:
      resources:
        requests:
          memory: 256Mi
          cpu: "0.2"
        limits:
          memory: 256Mi
          cpu: "0.5"
    userOperator:
      resources:
        requests:
          memory: 512Mi
          cpu: "0.2"
        limits:
          memory: 512Mi
          cpu: "0.5"
EOF
}

createOrdersTopic() {
oc apply -n strimzi -f- <<EOF
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: orders
  labels:
    strimzi.io/cluster: my-cluster
  namespace: strimzi
spec:
  partitions: 40
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
EOF
}

createQueueTopic() {
oc apply -n strimzi -f- <<EOF
apiVersion: kafka.strimzi.io/v1beta1
kind: KafkaTopic
metadata:
  name: queue
  labels:
    strimzi.io/cluster: my-cluster
  namespace: strimzi
spec:
  partitions: 40
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
EOF
}

createEphemeralCluster
#createStatefulCluster
createOrdersTopic
createQueueTopic
