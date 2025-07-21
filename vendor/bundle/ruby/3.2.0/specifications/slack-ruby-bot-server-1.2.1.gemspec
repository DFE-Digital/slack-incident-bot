# -*- encoding: utf-8 -*-
# stub: slack-ruby-bot-server 1.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "slack-ruby-bot-server".freeze
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Doubrovkine".freeze]
  s.date = "2022-03-07"
  s.email = ["dblock@dblock.org".freeze]
  s.homepage = "https://github.com/slack-ruby/slack-ruby-bot-server".freeze
  s.rubygems_version = "3.4.20".freeze
  s.summary = "A Grape API serving a Slack bot to multiple teams.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<async>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<foreman>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<grape>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<grape-roar>.freeze, [">= 0.4.0"])
  s.add_runtime_dependency(%q<grape-swagger>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<kaminari-grape>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rack-cors>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rack-rewrite>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rack-server-pages>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<slack-ruby-client>.freeze, [">= 0"])
end
