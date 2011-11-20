Gem::Specification.new do |s|
  s.name              = "similie"
  s.version           = "0.3.1"
  s.date              = "2011-11-20"
  s.authors           = "Bharanee Rathna"
  s.email             = "deepfryed@gmail.com"
  s.summary           = "compute image fingerprints and similarity"
  s.description       = "similie is an image fingerprinting & comparison utility"
  s.homepage          = "http://github.com/deepfryed/similie"
  s.files             = Dir["ext/**/*.{c,cc,h}"] + %w(README.rdoc ext/extconf.rb) + Dir["test/*.rb"]
  s.extra_rdoc_files  = %w(README.rdoc)
  s.extensions        = %w(ext/extconf.rb)
  s.require_paths     = %w(lib)
end
