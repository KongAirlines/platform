#!/usr/bin/env ruby
# Standard-library validation only; does not call Konnect or alter configuration.
require 'yaml'
require 'json'
require 'set'

root = File.expand_path('../konnect', __dir__)
portals = YAML.load_file(File.join(root, 'foundations.yaml')).fetch('portals')
refs = Set.new
portals.each do |portal|
  visibility = portal.fetch('default_page_visibility')
  paths = Set.new
  contents = []
  snippets = portal.fetch('snippets').map { |snippet| snippet.fetch('name') }.to_set
  validate_content = lambda do |resource|
    ref = resource.fetch('ref')
    raise "Duplicate resource reference: #{ref}" unless refs.add?(ref)
    raise "Unexpected visibility: #{ref}" unless resource.fetch('visibility') == visibility
    raise "Unpublished content: #{ref}" unless resource.fetch('status') == 'published'
    filename = File.expand_path(resource.fetch('content'), root)
    raise "Content outside konnect directory: #{filename}" unless filename.start_with?(root + '/')
    content = File.read(filename)
    raise "Empty page or snippet: #{ref}" if content.strip.empty?
    raise "Missing front matter: #{ref}" unless content.start_with?("---\n")
    contents << [ref, content]
  end
  walk = lambda do |pages, parent|
    pages.each do |page|
      validate_content.call(page)
      slug = page.fetch('slug')
      raise "Child slug must be relative: #{slug}" if parent != '/' && slug.start_with?('/')
      url = '/' + [parent, slug].join('/').split('/').reject(&:empty?).join('/')
      raise "Duplicate page path: #{url}" unless paths.add?(url)
      walk.call(page.fetch('children', []), url)
    end
  end
  walk.call(portal.fetch('pages'), '/')
  portal.fetch('snippets').each { |snippet| validate_content.call(snippet) }
  expected = %w[/ /apis /guides /guides/getting-started /guides/application-access /guides/environments /about]
  raise "Missing required pages: #{portal.fetch('ref')}" unless expected.all? { |url| paths.include?(url) }

  contents.each do |ref, content|
    content.scan(/\]\((\/[^)\s]*)\)|(?:to=\"|href:\s*)(\/[^\s\"}]+)/).each do |markdown, component|
      url = (markdown || component).split('#').first
      raise "Broken local link in #{ref}: #{url}" unless paths.include?(url)
    end
    content.scan(/^  sidebar-(?:left|right): (.+)$/).flatten.each do |name|
      raise "Missing sidebar snippet in #{ref}: #{name}" unless snippets.include?(name)
    end
  end
  menu = JSON.parse(File.read(File.join(root, portal.fetch('customization').fetch('menu'))))
  links = menu.fetch('main') + menu.fetch('footer_bottom') + menu.fetch('footer_sections').flat_map { |s| s.fetch('items') }
  links.reject { |link| link.fetch('external') }.each do |link|
    raise "Menu target does not exist: #{link.fetch('path')}" unless paths.include?(link.fetch('path'))
  end
  puts "Portal content valid: #{portal.fetch('ref')} (#{paths.size} pages, #{snippets.size} snippets)"
end
