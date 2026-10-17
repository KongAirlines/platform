#!/usr/bin/env bash
set -euo pipefail

: "${KONGAIRLINES_GATEWAY_URL:?set KONGAIRLINES_GATEWAY_URL}"
: "${KONGAIRLINES_JWT_JHAMBY:?set KONGAIRLINES_JWT_JHAMBY}"

readonly BASE_URL="${KONGAIRLINES_GATEWAY_URL%/}"
work_dir="$(mktemp -d)"
trap 'rm -rf "${work_dir}"' EXIT

request_status() {
  local output_file="$1"
  shift
  curl --silent --show-error --output "${output_file}" --write-out '%{http_code}' "$@"
}

assert_status() {
  local expected="$1"
  local actual="$2"
  local description="$3"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "${description}: expected HTTP ${expected}, got ${actual}" >&2
    exit 1
  fi
}

assert_success() {
  local actual="$1"
  local description="$2"
  if [[ ! "${actual}" =~ ^2[0-9][0-9]$ ]]; then
    echo "${description}: expected a successful response, got HTTP ${actual}" >&2
    exit 1
  fi
}

status="$(request_status "${work_dir}/flights.json" "${BASE_URL}/flights")"
assert_success "${status}" "Flights without credentials"

status="$(request_status "${work_dir}/destinations.json" "${BASE_URL}/destinations/SFO")"
assert_success "${status}" "Destinations without credentials"

for path in bookings customer; do
  status="$(request_status "${work_dir}/${path}-missing.json" "${BASE_URL}/${path}")"
  assert_status 401 "${status}" "${path} without JWT"

  status="$(request_status "${work_dir}/${path}-invalid.json" \
    --header 'Authorization: Bearer invalid.jwt.value' \
    "${BASE_URL}/${path}")"
  assert_status 401 "${status}" "${path} with invalid JWT"
done

status="$(request_status "${work_dir}/bookings-valid.json" \
  --header "Authorization: Bearer ${KONGAIRLINES_JWT_JHAMBY}" \
  "${BASE_URL}/bookings")"
assert_status 200 "${status}" "Bookings with valid JWT"
jq -e 'type == "array"' "${work_dir}/bookings-valid.json" >/dev/null

status="$(request_status "${work_dir}/customer-valid.json" \
  --header "Authorization: Bearer ${KONGAIRLINES_JWT_JHAMBY}" \
  "${BASE_URL}/customer")"
assert_status 200 "${status}" "Customer with valid JWT"
jq -e '.username == "jhamby"' "${work_dir}/customer-valid.json" >/dev/null

status="$(request_status "${work_dir}/customer-forged.json" \
  --header "Authorization: Bearer ${KONGAIRLINES_JWT_JHAMBY}" \
  --header 'X-Consumer-Username: jdoe' \
  "${BASE_URL}/customer")"
assert_status 200 "${status}" "Customer with forged identity header"
jq -e '.username == "jhamby"' "${work_dir}/customer-forged.json" >/dev/null

echo "Gateway authentication checks passed."
