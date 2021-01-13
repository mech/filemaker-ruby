# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'filemaker/version'

Gem::Specification.new do |spec|
  spec.name          = 'filemaker'
  spec.version       = Filemaker::VERSION
  spec.authors       = ['mech']
  spec.email         = ['mech@me.com']
  spec.summary       = 'A Ruby wrapper to FileMaker XML API.'
  spec.description   = 'Provides ActiveModel-like object to read and write.'
  spec.homepage      = 'https://github.com/mech/filemaker-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'typhoeus'
  spec.add_runtime_dependency 'nokogiri', '>= 1.11.0.rc4'
  spec.add_runtime_dependency 'activemodel'
  spec.add_runtime_dependency 'globalid'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'pry-byebug'
end
