#!/bin/bash

set -eu

source ../config-defaults.sh

cp *.yaml *.yml ../manifests/user

export IMAGE_REGISTRY_HTTP_SECRET=$(openssl rand -hex 64)

for i in *-config.yml; do
  envsubst < $i > ../manifests/user/$i
done

oc --config=../pki/admin.kubeconfig create configmap kubelet-serving-ca --dry-run -oyaml -n openshift-config-managed --from-file=ca-bundle.crt=../pki/root-ca.pem > ../manifests/user/kubelet-serving-ca-configmap.yaml
