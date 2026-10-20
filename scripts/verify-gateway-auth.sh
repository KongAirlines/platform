#!/usr/bin/env bash
set -euo pipefail

: "${KONGAIRLINES_GATEWAY_URL:?set the reachable Gateway proxy URL}"
: "${KONGAIRLINES_TEST_API_KEY:?set an approved Portal application API key}"
base_url="${KONGAIRLINES_GATEWAY_URL%/}"
work_dir="$(mktemp -d)"
trap 'rm -rf "${work_dir}"' EXIT

check() {
  local expected="$1" label="$2" endpoint="$3"
  shift 3
  local actual
  actual="$(curl --silent --show-error --max-time 30 --output "${work_dir}/response.json" \
    --write-out '%{http_code}' "$@" "${base_url}${endpoint}")"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "${label}: expected ${expected}, got ${actual}" >&2
    exit 1
  fi
  echo "PASS ${label}"
}

for endpoint in flights destinations; do
  check 200 "${endpoint} without credentials" "/${endpoint}"
done
for endpoint in bookings customer; do
  check 401 "${endpoint} without credentials" "/${endpoint}"
  check 401 "${endpoint} with invalid key" "/${endpoint}" --header 'X-API-Key: invalid-test-key'
  check 401 "${endpoint} with forged identity only" "/${endpoint}" \
    --header 'X-KongAir-Account-ID: 11111111-1111-4111-8111-111111111111' \
    --header 'X-Consumer-Username: jdoe'
  check 200 "${endpoint} with approved application" "/${endpoint}" \
    --header "X-API-Key: ${KONGAIRLINES_TEST_API_KEY}"
done
account_id="$(jq -er '.id | select(test("^[0-9a-f-]{36}$"))' "${work_dir}/response.json")"
check 200 "forged account cannot replace authenticated application" /customer \
  --header "X-API-Key: ${KONGAIRLINES_TEST_API_KEY}" \
  --header 'X-KongAir-Account-ID: 11111111-1111-4111-8111-111111111111' \
  --header 'X-Consumer-Username: jdoe'
jq -e --arg account "${account_id}" '.id == $account' "${work_dir}/response.json" >/dev/null

if [[ -n "${KONGAIRLINES_SECOND_API_KEY:-}" ]]; then
  check 200 "first application bookings" /bookings --header "X-API-Key: ${KONGAIRLINES_TEST_API_KEY}"
  ticket="$(jq -er '.[0].ticket_number' "${work_dir}/response.json")"
  check 200 "second application customer" /customer --header "X-API-Key: ${KONGAIRLINES_SECOND_API_KEY}"
  jq -e --arg account "${account_id}" '.id != $account' "${work_dir}/response.json" >/dev/null
  check 404 "second application cannot read first application booking" "/bookings/${ticket}" \
    --header "X-API-Key: ${KONGAIRLINES_SECOND_API_KEY}"
else
  echo "SKIP two-application isolation: KONGAIRLINES_SECOND_API_KEY is not set"
fi
if [[ -n "${KONGAIRLINES_UNREGISTERED_API_KEY:-}" ]]; then
  for endpoint in bookings customer; do
    check 403 "${endpoint} rejects an unregistered application key" "/${endpoint}" \
      --header "X-API-Key: ${KONGAIRLINES_UNREGISTERED_API_KEY}"
  done
else
  echo "SKIP unregistered application: KONGAIRLINES_UNREGISTERED_API_KEY is not set"
fi
if [[ -n "${KONGAIRLINES_ROTATED_API_KEY:-}" ]]; then
  check 200 "rotated key preserves the application account" /customer \
    --header "X-API-Key: ${KONGAIRLINES_ROTATED_API_KEY}"
  jq -e --arg account "${account_id}" '.id == $account' "${work_dir}/response.json" >/dev/null
else
  echo "SKIP key rotation: KONGAIRLINES_ROTATED_API_KEY is not set"
fi
