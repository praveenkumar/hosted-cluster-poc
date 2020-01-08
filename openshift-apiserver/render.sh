#!/bin/bash

set -eu

source ../config-defaults.sh
source ../lib/common.sh

CABUNDLE="$(encode ../pki/root-ca.pem)"

# managed
export OPENSHIFT_APISERVER_IMAGE=$(image_for openshift-apiserver)
envsubst < podman_openshiftApiserver > ../manifests/managed/run-openshift-apiserver.sh
chmod +x ../manifests/managed/run-openshift-apiserver.sh

# user
rm -f ../manifests/user/openshift-apiserver-apiservices.yaml
for apiservice in v1.apps.openshift.io v1.authorization.openshift.io v1.build.openshift.io v1.image.openshift.io v1.oauth.openshift.io v1.project.openshift.io v1.quota.openshift.io v1.route.openshift.io v1.security.openshift.io v1.template.openshift.io v1.user.openshift.io; do
cat >> ../manifests/user/openshift-apiserver-apiservices.yaml <<EOF 
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  name: ${apiservice}
spec:
  caBundle: ${CABUNDLE}
  group: ${apiservice#*.}
  groupPriorityMinimum: 9900
  service:
    name: openshift-apiserver
    namespace: default
  version: v1
  versionPriority: 15
EOF
done

for i in openshift-apiserver-user-*.yaml ; do
  envsubst < $i > ../manifests/user/$i
done
