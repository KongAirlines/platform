#!/usr/bin/env bash
set -euo pipefail

readonly BASE_SHA="${1:?usage: $0 <base-sha> <head-sha>}"
readonly HEAD_SHA="${2:?usage: $0 <base-sha> <head-sha>}"

while IFS= read -r provenance_file; do
  artifact="$(basename "${provenance_file}" .provenance.yaml)"

  case "${artifact}" in
    bookings)
      expected_repository="KongAirlines/bookings"
      ;;
    customer-information)
      expected_repository="KongAirlines/customer"
      ;;
    destinations)
      expected_repository="KongAirlines/destinations"
      ;;
    flights)
      expected_repository="KongAirlines/flights"
      ;;
    *)
      echo "unsupported production provenance file: ${provenance_file}" >&2
      exit 1
      ;;
  esac

  source_repository="$(awk '$1 == "source_repository:" { print $2 }' "${provenance_file}")"
  source_commit="$(awk '$1 == "source_commit:" { print $2 }' "${provenance_file}")"

  if [[ "${source_repository}" != "${expected_repository}" ]]; then
    echo "unexpected source repository in ${provenance_file}: ${source_repository}" >&2
    exit 1
  fi

  if [[ ! "${source_commit}" =~ ^[0-9a-f]{40}$ ]]; then
    echo "invalid source commit in ${provenance_file}: ${source_commit}" >&2
    exit 1
  fi

  printf '%s\t%s\n' "${source_repository}" "${source_commit}"
done < <(
  git diff --name-only "${BASE_SHA}" "${HEAD_SHA}" -- \
    'gateway/prod/*.provenance.yaml'
)
