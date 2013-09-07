Gem::Specification.new do |s|
  s.name              = "similie"
  s.version           = "0.4.0"
  s.authors           = ["Bharanee Rathna", "Ivan Kuchin"]
  s.email             = "deepfryed@gmail.com"
  s.summary           = "compute image fingerprints and similarity"
  s.description       = "similie is an image fingerprinting & comparison utility"
  s.homepage          = "http://github.com/deepfryed/similie"
  s.license           = "GPL"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables       = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extensions        = `git ls-files -- ext/**/extconf.rb`.split("\n")
  s.require_paths     = %w[lib]

  s.add_development_dependency 'rspec'
end
