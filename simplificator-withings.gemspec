# -*- encoding: utf-8 -*-

Gem::Specification.new do |spec|
  spec.name = %q{simplificator-withings}
  spec.version = "0.7.1"
  spec.authors = ["simplificator", "jmaddi", 'invernizzi', 'sreuterle']
  spec.date = %q{2011-04-18}
  spec.description = %q{A withings API implementation in ruby. Created for the evita project at evita.ch}
  spec.summary = %q{API implementation for withings.com}
  spec.email = %q{info@simplificator.com}

  spec.homepage = %q{http://github.com/simplificator/simplificator-withings}

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.license = "Sea LICENSE"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "minitest", "~> 5.4"

  spec.add_development_dependency "mocha", "~> 1.1"


  spec.add_dependency 'httparty', "~> 0.13"
end


