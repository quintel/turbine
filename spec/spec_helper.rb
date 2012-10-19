require 'rspec'
require 'simplecov'

SimpleCov.start do
  add_filter('/spec/')

  add_group 'Core' do |src|
    path = src.filename

    path.include?('/lib/turbine/') &&
      ! path.include?('/turbine/pipeline/') &&
      ! path.include?('/turbine/traversal/') &&
      ! path.end_with?('version.rb')
  end
  add_group 'Pipeline',  'lib/turbine/pipeline'
  add_group 'Traversal', 'lib/turbine/traversal'
end

require 'turbine'

Dir['./spec/support/**/*.rb'].map { |file| require file }

RSpec.configure do |config|
  # Use only the new "expect" syntax.
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  # Tries to find examples / groups with the focus tag, and runs them. If no
  # examples are focues, run everything. Prevents the need to specify
  # `--tag focus` when you only want to run certain examples.
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true

  # Allow adding examples to a filter group with only a symbol.
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
