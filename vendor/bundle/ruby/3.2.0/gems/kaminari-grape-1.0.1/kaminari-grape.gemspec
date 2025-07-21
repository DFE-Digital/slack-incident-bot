# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kaminari/grape/version'

Gem::Specification.new do |spec|
  spec.name          = "kaminari-grape"
  spec.version       = Kaminari::Grape::VERSION
  spec.authors       = ["Akira Matsuda"]
  spec.email         = ["ronnie@dio.jp"]

  spec.summary       = 'Kaminari Grape adapter'
  spec.description   = 'kaminari-grape connects Kaminari and Grape'
  spec.homepage      = 'https://github.com/kaminari/kaminari-grape'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'test-unit-activesupport'
  spec.add_development_dependency 'test-unit-rr'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'
  spec.add_dependency 'kaminari-core', '~> 1.0'
  spec.add_dependency 'grape'
end
