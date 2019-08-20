#!/bin/bash

createNamespace() {
    oc new-project tekton --display-name="Tekton" --description="Tekton"
}

createOperatorGroup() {
    oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: my-og
  namespace: tekton
spec: {}
EOF
}

createCatalogSourceConfig() {
    oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: CatalogSourceConfig
metadata:
  name: my-csc-tekton
  namespace: openshift-marketplace
spec:
  targetNamespace: tekton
  packages: openshift-pipelines-operator
EOF
}

createSubscription() {
    oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: tekton
  namespace: tekton
spec:
  source: my-csc-tekton
  sourceNamespace: tekton
  name: tekton
  channel: dev-preview
EOF
}

createNamespace
createOperatorGroup
createCatalogSourceConfig
createSubscription
