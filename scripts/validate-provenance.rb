#!/usr/bin/env ruby
require 'yaml'
require 'digest'

# Hashing and comparison across files remain outside native manifest policy.
%w[bookings customer destinations flights].each do |repository|
  artifact = repository == 'customer' ? 'customer-information' : repository
  state = "gateway/prod/#{artifact}.yaml"
  provenance = YAML.safe_load_file("gateway/prod/#{artifact}.provenance.yaml", aliases: false)
  abort("#{artifact}: unexpected source repository") unless provenance.fetch('source_repository') == "KongAirlines/#{repository}"
  abort("#{artifact}: invalid source commit") unless provenance.fetch('source_commit').match?(/\A[0-9a-f]{40}\z/)
  abort("#{artifact}: artifact checksum mismatch") unless provenance.fetch('sha256') == Digest::SHA256.file(state).hexdigest
end
