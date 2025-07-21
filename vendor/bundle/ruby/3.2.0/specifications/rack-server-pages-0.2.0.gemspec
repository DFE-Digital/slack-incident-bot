# -*- encoding: utf-8 -*-
# stub: rack-server-pages 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rack-server-pages".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Masato Igarashi".freeze, "Daniel Doubrovkine".freeze]
  s.date = "2024-10-19"
  s.description = "Rack middleware and appilcation for serving dynamic pages in very simple way.\n                     There are no controllers and no models, just only views like a asp, jsp and php!".freeze
  s.email = ["m@igrs.jp".freeze]
  s.homepage = "http://github.com/migrs/rack-server-pages".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Rack middleware and appilcation for serving dynamic pages in very simple way.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rack>.freeze, [">= 0"])
end
