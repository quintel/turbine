require 'rake'
require 'rake/clean'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'turbine/version'

CLOBBER.include %w( pkg *.gem doc coverage measurements )

# Helpers --------------------------------------------------------------------

require 'date'

def replace_header(head, header_name, value)
  head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{value}'" }
end

# Build Tasks ----------------------------------------------------------------

desc 'Build the gem, and push to Github'
task :release => :build do
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end

  sh "git commit --allow-empty -a -m 'Release #{Turbine::VERSION}'"
  sh "git tag v#{Turbine::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{Turbine::VERSION}"

  puts "Push to Rubygems.org with"
  puts "  gem push pkg/turbine-#{Turbine::VERSION}.gem"
end

desc 'Builds the gem'
task :build => [:gemspec] do
  sh "mkdir -p pkg"
  sh "gem build turbine.gemspec"
  sh "mv turbine-#{Turbine::VERSION}.gem pkg"
end

desc 'Create a fresh gemspec'
task :gemspec => :validate do
  gemspec_file = File.expand_path('../turbine.gemspec', __FILE__)

  # Read spec file and split out the manifest section.
  spec = File.read(gemspec_file)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")

  # Replace name version and date.
  replace_header head, :name,              'turbine-graph'
  replace_header head, :rubyforge_project, 'turbine-graph'
  replace_header head, :version,            Turbine::VERSION
  replace_header head, :date,               Date.today.to_s

  # Determine file list from git ls-files.
  files = `git ls-files`.
    split("\n").
    sort.
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(doc|pkg|spec|tasks)/ }

  # Format list for the gemspec.
  files = files.map { |file| "    #{file}" }.join("\n")

  # Piece file back together and write.
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head, manifest, tail].join("  # = MANIFEST =\n")
  File.open(gemspec_file, 'w') { |io| io.write(spec) }

  puts "Updated #{gemspec_file}"
end

task :validate do
  unless Dir['lib/*'] - %w(lib/turbine.rb lib/turbine)
    puts 'The lib/ directory should only contain a turbine.rb file, and a ' \
         'turbine/ directory'
    exit!
  end

  unless Dir['VERSION*'].empty?
    puts 'A VERSION file at root level violates Gem best practices'
    exit!
  end
end

# Coverage -------------------------------------------------------------------

task :coverage do
  ENV['COVERAGE'] = 'true'
  exec 'bundle exec rspec'
end

# Documentation --------------------------------------------------------------

begin
  require 'yard'
  require 'yard-tomdoc'
  YARD::Rake::YardocTask.new do |doc|
    doc.options << '--no-highlight'
  end
rescue LoadError
  desc 'yard task requires that the yard gem is installed'
  task :yard do
    abort 'YARD is not available. In order to run yard, you must: gem ' \
          'install yard'
  end
end

# Console --------------------------------------------------------------------

namespace :console do
  task :run do
    command = system("which pry > /dev/null 2>&1") ? 'pry' : 'irb'
    exec "#{ command } -I./lib -r./lib/turbine.rb"
  end

  desc 'Open a pry or irb session with a stub graph on `Turbine.stub`'
  task :stub do
    command = system("which pry > /dev/null 2>&1") ? 'pry' : 'irb'
    exec "#{ command } -I./lib -r./lib/turbine.rb -r./examples/family.rb -r./examples/energy.rb"
  end
end

desc 'Open a pry or irb session preloaded with Turbine'
task console: ['console:run']
