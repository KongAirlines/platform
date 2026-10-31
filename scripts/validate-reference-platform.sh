#!/usr/bin/env bash
set -euo pipefail

readonly OBSOLETE_PATTERN='koct[l]|konnect-[o]rchestrator|ko-[p]atch'

ruby scripts/validate-provenance.rb

if grep -ERin "${OBSOLETE_PATTERN}" README.md .github gateway konnect scripts; then
  echo "obsolete Reference Platform tooling is not allowed" >&2
  exit 1
fi
