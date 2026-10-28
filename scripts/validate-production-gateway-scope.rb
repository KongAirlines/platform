#!/usr/bin/env ruby
# Validate the entire reconciliation unit without calling Konnect.
require 'yaml'
require 'json'

root = File.expand_path('..', __dir__)
manifest_path = File.join(root, 'konnect/production-gateway.yaml')
manifest = YAML.load_file(manifest_path)
control_plane = manifest.fetch('control_planes').find { |cp| cp.fetch('ref') == 'kongairlines-prod' }
files = control_plane.fetch('_deck').fetch('files')
expected_tags = ['env-prod']
entity_fields = %w[services routes plugins consumers jwt_secrets upstreams]

validate_entities = lambda do |state, label|
  walk = lambda do |parent|
    entity_fields.each do |field|
      parent.fetch(field, []).each do |entity|
        unless expected_tags.all? { |tag| entity.fetch('tags', []).include?(tag) }
          raise "#{label}: #{field} entity is missing the production reconciliation tag"
        end
        walk.call(entity)
      end
    end
  end
  walk.call(state)
end

raise 'Production aggregate must include state files' if files.empty?
files.each do |file|
  filename = File.expand_path(file, File.dirname(manifest_path))
  state = YAML.load_file(filename, aliases: true)
  tags = state.fetch('_info').fetch('select_tags').uniq
  unless tags == expected_tags
    raise "#{file}: production aggregate select_tags must be #{expected_tags.inspect}, got #{tags.inspect}"
  end
  validate_entities.call(state, file)
end

unless ARGV.empty?
  # deck file render removes _info, so check selection on the source files
  # and verify the resulting entities and authentication configuration here.
  rendered = JSON.parse(File.read(ARGV.fetch(0)))
  validate_entities.call(rendered, 'rendered production aggregate')
  ace = rendered.fetch('plugins').select { |plugin| plugin.fetch('name') == 'ace' }
  unless ace.size == 1 && ace.first.fetch('config').fetch('anonymous') == 'kongairlines-anonymous'
    raise 'Rendered production aggregate must preserve the ACE anonymous fallback'
  end
end

puts "Production reconciliation scope valid: #{expected_tags.join(', ')} (#{files.size} files)"
