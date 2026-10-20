#!/usr/bin/env bash
set -euo pipefail

readonly ARTIFACTS=(bookings customer-information destinations flights)
readonly REPOSITORIES=(bookings customer destinations flights)
readonly OBSOLETE_PATTERN='koct[l]|konnect-[o]rchestrator|ko-[p]atch'

for index in "${!ARTIFACTS[@]}"; do
  artifact="${ARTIFACTS[${index}]}"
  repository="${REPOSITORIES[${index}]}"
  state_file="gateway/prod/${artifact}.yaml"
  provenance_file="gateway/prod/${artifact}.provenance.yaml"

  if grep -H '^plugins:' "${state_file}"; then
    echo "service production state must not declare global plugins" >&2
    exit 1
  fi

  expected_repository="$(awk '$1 == "source_repository:" { print $2 }' "${provenance_file}")"
  expected_commit="$(awk '$1 == "source_commit:" { print $2 }' "${provenance_file}")"
  expected_checksum="$(awk '$1 == "sha256:" { print $2 }' "${provenance_file}")"
  actual_checksum="$(sha256sum "${state_file}" | cut -d ' ' -f1)"

  [[ "${expected_repository}" == "KongAirlines/${repository}" ]]
  [[ "${expected_commit}" =~ ^[0-9a-f]{40}$ ]]
  [[ "${expected_checksum}" == "${actual_checksum}" ]]
done

grep -Fq 'name: ace' gateway/dev/ace.yaml
grep -Fq 'match_policy: required' gateway/dev/ace.yaml
grep -Fq 'name: ace' gateway/prod/ace.yaml
grep -Fq 'match_policy: required' gateway/prod/ace.yaml

grep -Fq 'name: kongairlines-key-auth-dev' konnect/foundations.yaml
grep -Fq 'name: kongairlines-key-auth-prod' konnect/foundations.yaml
grep -Fq 'anonymous: kongairlines-anonymous' gateway/dev/ace.yaml
grep -Fq 'anonymous: kongairlines-anonymous' gateway/prod/ace.yaml
grep -Fq 'kongctl apply -f konnect/access.yaml' .github/workflows/apply-foundations.yaml
grep -Fq 'Kong/kongctl/issues/2534' .github/workflows/apply-foundations.yaml

for stage in dev prod; do
  jwt_file="gateway/${stage}/jwt-consumers.yaml"
  for username in jhamby jdoe jsmith; do
    grep -Fq "username: ${username}" "${jwt_file}"
    grep -Fq "key: kongairlines-${stage}-${username}" "${jwt_file}"
  done
  grep -Fq 'algorithm: RS256' "${jwt_file}"
  if grep -Eq '^[[:space:]]*(private_key|password|token):' "${jwt_file}"; then
    echo "JWT signing credentials must not be committed" >&2
    exit 1
  fi
done

if grep -Eq '^(services|routes):' gateway/dev/ace.yaml gateway/prod/ace.yaml; then
  echo "platform ACE state must contain only the global plugin and anonymous Consumer" >&2
  exit 1
fi

if grep -ERin "${OBSOLETE_PATTERN}" README.md .github gateway konnect scripts; then
  echo "obsolete Reference Platform tooling is not allowed" >&2
  exit 1
fi
