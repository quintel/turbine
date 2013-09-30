# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.required_rubygems_version = '>= 1.3.6'

  # The following four lines are automatically updated by the "gemspec"
  # rake task. It it completely safe to edit them, but using the rake task
  # is easier.
  s.name              = 'turbine-graph'
  s.version           = '0.1.3'
  s.date              = '2013-09-27'
  s.rubyforge_project = 'turbine-graph'

  # You may safely edit the section below.

  s.platform     = Gem::Platform::RUBY

  s.authors      = [ 'Anthony Williams',
                     'Dennis Schoenmakers' ]

  s.email        = [ 'hi@antw.me',
                     'dennis.schoenmakers@quintel.com' ]

  s.homepage     = 'http://github.com/quintel/turbine'
  s.summary      = 'An in-memory graph database written in Ruby.'
  s.description  = 'An experiment in graph databases, with Ruby...'
  s.license      = 'BSD'

  s.require_path = 'lib'

  s.add_development_dependency 'rake',  '>= 0.9.0'
  s.add_development_dependency 'rspec', '>= 2.11.0'

  s.rdoc_options     = ['--charset=UTF-8']
  s.extra_rdoc_files = %w[LICENSE README.md]

  # The manifest is created by the "gemspec" rake task. Do not edit it
  # directly; your changes will be wiped out when you next run the task.

  # = MANIFEST =
  s.files = %w[
    Gemfile
    Guardfile
    LICENSE
    README.md
    Rakefile
    examples/energy.rb
    examples/family.rb
    lib/turbine.rb
    lib/turbine/algorithms/filtered_tarjan.rb
    lib/turbine/algorithms/tarjan.rb
    lib/turbine/edge.rb
    lib/turbine/errors.rb
    lib/turbine/graph.rb
    lib/turbine/node.rb
    lib/turbine/pipeline/README.mdown
    lib/turbine/pipeline/dsl.rb
    lib/turbine/pipeline/expander.rb
    lib/turbine/pipeline/filter.rb
    lib/turbine/pipeline/journal.rb
    lib/turbine/pipeline/journal_filter.rb
    lib/turbine/pipeline/pump.rb
    lib/turbine/pipeline/segment.rb
    lib/turbine/pipeline/sender.rb
    lib/turbine/pipeline/split.rb
    lib/turbine/pipeline/trace.rb
    lib/turbine/pipeline/transform.rb
    lib/turbine/pipeline/traversal.rb
    lib/turbine/pipeline/unique.rb
    lib/turbine/properties.rb
    lib/turbine/traversal/base.rb
    lib/turbine/traversal/breadth_first.rb
    lib/turbine/traversal/depth_first.rb
    lib/turbine/version.rb
    turbine.gemspec
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*\.rb/ }
end
