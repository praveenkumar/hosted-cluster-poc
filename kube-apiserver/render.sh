#!/bin/bash

set -eu

source ../config-defaults.sh
source ../lib/common.sh

export OAUTH_ROUTE="oauth-openshift.${INGRESS_SUBDOMAIN}"

cat > ../pki/oauthMetadata.json <<EOF
{
  "issuer": "https://${OAUTH_ROUTE}",
  "authorization_endpoint": "https://${OAUTH_ROUTE}/oauth/authorize",
  "token_endpoint": "https://${OAUTH_ROUTE}/oauth/token",
  "scopes_supported": [
    "user:check-access",
    "user:full",
    "user:info",
    "user:list-projects",
    "user:list-scoped-projects"
  ],
  "response_types_supported": [
    "code",
    "token"
  ],
  "grant_types_supported": [
    "authorization_code",
    "implicit"
  ],
  "code_challenge_methods_supported": [
    "plain",
    "S256"
  ]
}
EOF

envsubst < config.yaml > ../pki/config-apiserver.yaml

export HYPERKUBE_IMAGE=$(image_for hyperkube)
envsubst < podman_kubeApiserver > ../manifests/managed/run-kube-apiserver.sh
chmod +x ../manifests/managed/run-kube-apiserver.sh
