#!/bin/bash

createNamespace() {
    oc new-project strimzi --display-name="Kafka" --description="Kafka"
}

createOperatorGroup() {
    oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: my-og
  namespace: strimzi
spec: {}
EOF

}

createCatalogSourceConfig() {
    oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: CatalogSourceConfig
metadata:
  name: my-csc
  namespace: openshift-marketplace
spec:
  targetNamespace: strimzi
  packages: amq-streams
EOF
}

createSubscription() {
    oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: amq-streams
  namespace: strimzi
spec:
  source: my-csc
  sourceNamespace: strimzi
  name: amq-streams
  channel: stable
EOF
}

createNamespace
createOperatorGroup
createCatalogSourceConfig
createSubscription
