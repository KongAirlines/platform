#!/usr/bin/env bash
set -euo pipefail

readonly ARTIFACTS=(bookings customer-information destinations flights)
readonly REPOSITORIES=(bookings customer destinations flights)
readonly OBSOLETE_PATTERN='koct[l]|konnect-[o]rchestrator|ko-[p]atch'

if grep -H '^plugins:' gateway/prod/*.yaml; then
  echo "service production state must not declare global plugins" >&2
  exit 1
fi

for index in "${!ARTIFACTS[@]}"; do
  artifact="${ARTIFACTS[${index}]}"
  repository="${REPOSITORIES[${index}]}"
  state_file="gateway/prod/${artifact}.yaml"
  provenance_file="gateway/prod/${artifact}.provenance.yaml"

  expected_repository="$(awk '$1 == "source_repository:" { print $2 }' "${provenance_file}")"
  expected_commit="$(awk '$1 == "source_commit:" { print $2 }' "${provenance_file}")"
  expected_checksum="$(awk '$1 == "sha256:" { print $2 }' "${provenance_file}")"
  actual_checksum="$(sha256sum "${state_file}" | cut -d ' ' -f1)"

  [[ "${expected_repository}" == "KongAirlines/${repository}" ]]
  [[ "${expected_commit}" =~ ^[0-9a-f]{40}$ ]]
  [[ "${expected_checksum}" == "${actual_checksum}" ]]
done

if grep -ERin "${OBSOLETE_PATTERN}" README.md .github gateway konnect scripts; then
  echo "obsolete Reference Platform tooling is not allowed" >&2
  exit 1
fi
