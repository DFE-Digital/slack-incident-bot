# -*- encoding: utf-8 -*-
# stub: kaminari-grape 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "kaminari-grape".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Akira Matsuda".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-01-25"
  s.description = "kaminari-grape connects Kaminari and Grape".freeze
  s.email = ["ronnie@dio.jp".freeze]
  s.homepage = "https://github.com/kaminari/kaminari-grape".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Kaminari Grape adapter".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<bundler>.freeze, ["~> 1.12"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<test-unit-activesupport>.freeze, [">= 0"])
  s.add_development_dependency(%q<test-unit-rr>.freeze, [">= 0"])
  s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
  s.add_development_dependency(%q<activerecord>.freeze, [">= 0"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<kaminari-core>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<grape>.freeze, [">= 0"])
end
