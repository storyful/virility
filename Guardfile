# frozen_string_literal: true

group :red_green_refactor, halt_on_fail: true do
  guard :rspec, cmd: 'bundle exec rspec' do
    require 'guard/rspec/dsl'
    dsl = Guard::RSpec::Dsl.new(self)

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)
  end

  rubocop_cli = ['--format', 'clang', 'lib', 'spec']

  guard :rubocop, all_on_start: false, cli: rubocop_cli do
    watch(%r{^lib/.*\.rb$})
    watch(%r{^spec/.*\.rb$})
  end
end
