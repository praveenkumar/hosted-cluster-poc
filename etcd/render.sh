#!/bin/bash

set -eu

source ../lib/common.sh
source ../config-defaults.sh

export ETCD_IMAGE=$(image_for etcd)
envsubst < podman_etcd > podman_etcd.rendered
