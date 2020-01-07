#!/bin/bash

set -eu

source ../lib/common.sh

envsubst < config.yaml > ../pki/config-scheduler.yaml

export HYPERKUBE_IMAGE=$(image_for hyperkube)
envsubst < podman_kubeScheduler > podman_kubeScheduler.rendered
