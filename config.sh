#!/usr/bin/env bash
# none, aws, or openstack
export PLATFORM=none

# network type
export NETWORK_TYPE=OpenShiftSDN

# the base domain for the cluster
export BASE_DOMAIN=nip.io

# the name external name on which to connect to the user cluster API server
# IMPACT: kube-apiserver cert generation and admin.kubeconfig server URL
export EXTERNAL_API_DNS_NAME=192.168.130.1.${BASE_DOMAIN}

# the external IP on which to connect to the user cluster API server
export EXTERNAL_API_IP_ADDRESS=$(dig +short ${EXTERNAL_API_DNS_NAME})

# the external port on which to connect to the user cluster API server
# IMPACT: admin.kubeconfig server URL
export EXTERNAL_API_PORT=6443

# the cluster IP to use for openshift-apiserver
export API_CLUSTERIP=172.30.0.20

# OKD/OCP release image from which to get component image pull specs
export RELEASE_IMAGE="quay.io/openshift-release-dev/ocp-release:4.2.13"

# the subdomain to be used for the ingress router
export INGRESS_SUBDOMAIN="apps-${EXTERNAL_API_DNS_NAME}"