if ENV['COVERAGE']
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
end
