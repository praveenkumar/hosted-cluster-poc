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
KUBEADMIN_PASSWORD=$(openssl rand -hex 24 | tr -d '\n')
echo $KUBEADMIN_PASSWORD > kubeadmin-password

for component in etcd kube-apiserver kube-controller-manager kube-scheduler openshift-apiserver; do
  pushd ${component}
  ./render.sh
  popd
done

sudo rm -fr /etc/k8s/pki
sudo mkdir -p /etc/k8s/
sudo cp -r pki /etc/k8s/

sudo mkdir -p /var/lib/etcd
sudo rm -fr /var/lib/etcd/*

pushd manifests/managed
for component in etcd kube-apiserver kube-controller-manager kube-scheduler; do
  ./run-${component}.sh
  sleep 10
done
popd

echo "Install complete!"
echo "To access the cluster as the system:admin user when using 'oc', run 'export $(pwd)/pki/admin.kubeconfig"
echo "To join additional nodes to the cluster, use the node-bootstrapper kubeconfig at $(pwd)/pki/kubelet-bootstrap.kubeconfig"
echo "Access the OpenShift web-console here: https://console-openshift-console.${INGRESS_SUBDOMAIN}"
echo "Login into the console with user: kubeadmin, password ${KUBEADMIN_PASSWORD}"
