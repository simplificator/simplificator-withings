# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{simplificator-withings}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["pascalbetz"]
  s.date = %q{2011-03-01}
  s.description = %q{A withings API implementation in ruby. Created for the evita project at evita.ch}
  s.email = %q{info@simplificator.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "lib/withings.rb",
     "lib/withings/base.rb",
     "lib/withings/connection.rb",
     "lib/withings/error.rb",
     "lib/withings/measurement_group.rb",
     "lib/withings/notification_description.rb",
     "lib/withings/user.rb",
     "simplificator-withings.gemspec",
  ]
  s.homepage = %q{http://github.com/simplificator/simplificator-withings}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{API implementation for withings.com}
  s.test_files = [
    "test/helper.rb",
     "test/users_test.rb",
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<httparty>, [">= 0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<httparty>, [">= 0"])
  end
end

