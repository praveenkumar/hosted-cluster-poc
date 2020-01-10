#!/bin/bash

source config-defaults.sh
source lib/common.sh

set -eu

# make-pki.sh does not remove the /pki directory and does not regenerate certs that already exist.
# If you wish to regenerate the PKI, remove the /pki directory.
rm -fr pki
echo "Creating PKI assets"
./make-pki.sh

echo "Retrieving release pull specs"
export RELEASE_PULLSPECS="$(mktemp)"
fetch_release_pullspecs

echo "Rendering manifests"
rm -rf manifests
mkdir -p manifests/managed manifests/user
cp pull-secret manifests/managed

KUBEADMIN_PASSWORD=$(openssl rand -hex 24 | tr -d '\n')
echo $KUBEADMIN_PASSWORD > kubeadmin-password

for component in etcd kube-apiserver kube-controller-manager kube-scheduler openshift-apiserver cluster-bootstrap openshift-controller-manager; do
  pushd ${component}
  ./render.sh
  popd
done

sudo rm -fr /etc/k8s
for component in kube-apiserver openshift-apiserver openshift-controller-manager; do
    sudo mkdir -p /etc/k8s/base/${component}
    sudo cp -r pki/*  /etc/k8s/base/${component}/
done

sudo mkdir -p /var/lib/etcd
sudo rm -fr /var/lib/etcd/*

sudo mkdir -p /etc/etcd
sudo rm -fr /etc/etcd/*

# Start basic K8s
pushd manifests/managed
for component in etcd kube-apiserver kube-controller-manager kube-scheduler; do
  ./run-${component}.sh
  sleep 10
done
popd

# Apply service and endpoint before starting the openshift-apiserver
kubectl --kubeconfig=pki/admin.kubeconfig apply -f manifests/user/openshift-apiserver-user-service.yaml
kubectl --kubeconfig=pki/admin.kubeconfig apply -f manifests/user/openshift-apiserver-user-endpoint.yaml

# Start openshift-apiserver
pushd manifests/managed
for component in openshift-apiserver; do
  ./run-${component}.sh
  sleep 10
done
popd

# Apply CRD's
kubectl --kubeconfig=pki/admin.kubeconfig apply -f manifests/user/

# Start openshift-controller-manager
pushd manifests/managed
for component in openshift-controller-manager; do
  ./run-${component}.sh
  sleep 10
done
popd

