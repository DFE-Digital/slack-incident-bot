# -*- encoding: utf-8 -*-
# stub: otr-activerecord 2.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "otr-activerecord".freeze
  s.version = "2.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jordan Hollinger".freeze]
  s.date = "2024-12-14"
  s.description = "Off The Rails ActiveRecord: Use ActiveRecord with Grape, Sinatra, Rack, or anything else! Formerly known as 'grape-activerecord'.".freeze
  s.email = "jordan.hollinger@gmail.com".freeze
  s.homepage = "https://github.com/jhollinger/otr-activerecord".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Off The Rails: Use ActiveRecord with Grape, Sinatra, Rack, or anything else!".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 6.0", "< 8.1"])
end
