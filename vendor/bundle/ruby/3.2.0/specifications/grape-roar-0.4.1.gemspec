# -*- encoding: utf-8 -*-
# stub: grape-roar 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "grape-roar".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Doubrovkine".freeze]
  s.date = "2017-07-14"
  s.description = "Use Roar with Grape".freeze
  s.email = ["dblock@dblock.org".freeze]
  s.homepage = "http://github.com/ruby-grape/grape-roar".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Enable Resource-Oriented Architectures in Grape API DSL".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<grape>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<multi_json>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<roar>.freeze, ["~> 1.1.0"])
end
