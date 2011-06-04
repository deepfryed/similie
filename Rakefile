require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/extensiontask'

CLEAN << FileList[ 'ext/Makefile', 'ext/similie.so' ]

begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

Jeweler::Tasks.new do |gem|
  gem.name        = 'similie'
  gem.summary     = 'Compute image fingerprints and similarity'
  gem.description = %q{
    Similie does image fingerprinting using discrete cosine transform
    and similarity comparison using Hamming distance on fingerprints.
  }
  gem.email       = 'deepfryed@gmail.com'
  gem.homepage    = 'http://github.com/deepfryed/similie'
  gem.authors     = ['Bharanee Rathna']
 
  gem.files = FileList[
    'lib/**/*.rb',
    'ext/*.{h,c}',
    'VERSION',
    'README'
  ]
  gem.extensions  = FileList[ 'ext/**/extconf.rb' ]
  gem.test_files  = FileList[ 'test/test_*.rb' ]
end

Jeweler::GemcutterTasks.new

Rake::ExtensionTask.new do |ext|
  ext.name    = 'similie'
  ext.ext_dir = 'ext'
  ext.lib_dir = 'ext'
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/test_*.rb'
  test.verbose = true
end

task :test    => [ :compile, :check_dependencies ]
task :default => :test
