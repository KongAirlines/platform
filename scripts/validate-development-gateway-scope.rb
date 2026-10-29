#!/usr/bin/env ruby
# Shared development sync must never select the service teams' Gateway state.
require 'yaml'

root = File.expand_path('..', __dir__)
manifest_path = File.join(root, 'konnect/development-gateway.yaml')
manifest = YAML.load_file(manifest_path)
control_planes = manifest.fetch('control_planes')
expected_tags = %w[env-dev owner-platform]
allowed_fields = %w[_format_version _info consumers plugins]

raise 'Development shared state must target a control plane' if control_planes.empty?
control_planes.each do |control_plane|
  label = control_plane.fetch('ref')
  deck = control_plane.fetch('_deck')
  files = deck.fetch('files')
  raise "#{label}: shared state files are required" if files.empty?
  if deck.fetch('flags', []).any? { |flag| flag.start_with?('--select-tag') }
    raise "#{label}: select tags must come from the state files"
  end

  consumers = []
  plugins = []
  files.each do |file|
    state = YAML.load_file(File.expand_path(file, File.dirname(manifest_path)))
    tags = state.fetch('_info').fetch('select_tags')
    unless tags.sort == expected_tags.sort
      raise "#{file}: shared select_tags must be #{expected_tags.inspect}"
    end
    unless (state.keys - allowed_fields).empty?
      raise "#{file}: shared state may contain only Consumers and global plugins"
    end
    consumers.concat(state.fetch('consumers', []))
    plugins.concat(state.fetch('plugins', []))
  end

  unless consumers.size == 1 && consumers.first.fetch('username') == 'kongairlines-anonymous' &&
      (consumers.first.keys - %w[username tags]).empty?
    raise "#{label}: shared state must contain only the anonymous Consumer without credentials"
  end
  unless plugins.size == 1 && plugins.first.fetch('name') == 'ace' &&
      plugins.first.fetch('config').fetch('match_policy') == 'required' &&
      plugins.first.fetch('config').fetch('anonymous') == 'kongairlines-anonymous' &&
      (plugins.first.keys & %w[service route consumer consumer_group]).empty?
    raise "#{label}: shared state must preserve global ACE with the anonymous fallback"
  end
  (consumers + plugins).each do |entity|
    unless (expected_tags - entity.fetch('tags', [])).empty?
      raise "#{label}: shared entity is missing its environment or ownership tag"
    end
  end
end

puts "Development shared reconciliation scope valid: #{expected_tags.join(', ')}"
