require 'rspec'
require 'rspec/collection_matchers'
require 'support/coverage'
require 'turbine'

Dir['./spec/{support,factories}/**/*.rb'].map do |file|
  require file unless file.end_with?('coverage.rb')
end

RSpec.configure do |config|
  # Use only the new "expect" syntax.
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  # Tries to find examples / groups with the focus tag, and runs them. If no
  # examples are focues, run everything. Prevents the need to specify
  # `--tag focus` when you only want to run certain examples.
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true

  # Factories are enabled on in integration tests.
  config.include Turbine::Spec::Factories, type: :integration,
    file_path: %r{spec\/integration}
end
