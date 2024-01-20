# frozen_string_literal: true

guard :bundler do
  watch('Gemfile')
  watch('Gemfile.lock')
end

guard :rubocop do
  watch(%r{.+\.rb$})
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'bundle exec rspec' do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  rails = dsl.rails
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  watch(rails.controllers) { |m| [rspec.spec.call("controllers/#{m[1]}_controller")] }
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }
end
