#!/bin/bash

createCluster() {
oc apply -n strimzi -f- <<EOF
apiVersion: kafka.strimzi.io/v1alpha1
kind: Kafka
metadata:
  name: my-cluster
  namespace: strimzi
spec:
  kafka:
    version: 2.1.0
    replicas: 3
    listeners:
      plain: {}
      tls: {}
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
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

createOrdersTopic() {
oc apply -n strimzi -f- <<EOF
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaTopic
metadata:
  name: orders
  labels:
    strimzi.io/cluster: my-cluster
  namespace: strimzi
spec:
  partitions: 4
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
EOF
}

createQueueTopic() {
oc apply -n strimzi -f- <<EOF
apiVersion: kafka.strimzi.io/v1alpha1
kind: KafkaTopic
metadata:
  name: queue
  labels:
    strimzi.io/cluster: my-cluster
  namespace: strimzi
spec:
  partitions: 4
  replicas: 3
  config:
    retention.ms: 604800000
    segment.bytes: 1073741824
EOF
}

createCluster
createOrdersTopic
createQueueTopic
