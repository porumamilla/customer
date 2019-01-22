#!/bin/bash
# Randomly delete pods in a Kubernetes namespace.
set -ex

: ${DELAY:=10}
: ${NAMESPACE:=dev}

while true; do
  kubectl \
    --namespace "${NAMESPACE}" \
    -o 'jsonpath={.items[*].metadata.name}' \
    get pods | \
      tr " " "\n" | \
      shuf | \
      head -n 1 |
      xargs -t --no-run-if-empty \
        kubectl --namespace "${NAMESPACE}" delete pod
  sleep "${DELAY}"
done