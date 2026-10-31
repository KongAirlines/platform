#!/usr/bin/env bash
set -euo pipefail
kongctl lint -f konnect/foundations.yaml -r lint/foundations.yaml --fail-severity error
for stage in dev prod; do
  deck file lint --analytics=false --state "gateway/${stage}/ace.yaml" "lint/ace-${stage}.yaml"
done
for artifact in bookings customer-information destinations flights; do
  deck file lint --analytics=false --state "gateway/prod/${artifact}.yaml" lint/promoted-gateway.yaml
done
