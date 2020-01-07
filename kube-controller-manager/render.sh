#!/bin/bash

set -eu

source ../config-defaults.sh
source ../lib/common.sh

envsubst < config.yaml > ../pki/config-controller.yaml

export HYPERKUBE_IMAGE=$(image_for hyperkube)
envsubst < podman_kubeController > podman_kubeController.rendered
