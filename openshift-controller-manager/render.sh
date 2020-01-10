#!/bin/bash

set -eu

source ../config-defaults.sh
source ../lib/common.sh

export DOCKER_BUILDER_IMAGE=$(image_for docker-builder)
export DEPLOYER_IMAGE=$(image_for deployer)
envsubst < config.yaml > ../pki/config-openshiftController.yaml

export OPENSHIFT_CONTROLLER_MANAGER_IMAGE=$(image_for openshift-controller-manager)

cp openshift-controller-manager-namespace.yaml ../manifests/user/00-openshift-controller-manager-namespace.yaml
cp leader-election-cluster-policy-controller-role.yaml ../manifests/user/leader-election-cluster-policy-controller-role.yaml
cp leader-election-cluster-policy-controller-rolebinding.yaml ../manifests/user/leader-election-cluster-policy-controller-rolebinding.yaml
cat > ../manifests/user/openshift-controller-manager-service-ca.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    service.beta.openshift.io/inject-cabundle: "true"
  name: openshift-service-ca
  namespace: openshift-controller-manager
data: {}
EOF

envsubst < podman_openshiftControllerManager > ../manifests/managed/run-openshift-controller-manager.sh
chmod +x ../manifests/managed/run-openshift-controller-manager.sh
