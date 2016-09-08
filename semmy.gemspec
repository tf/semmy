# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'semmy/version'

Gem::Specification.new do |spec|
  spec.name          = "semmy"
  spec.version       = Semmy::VERSION
  spec.authors       = ["Tim Fischbach"]
  spec.email         = ["mail@timfischbach.de"]

  spec.summary       = 'Rake tasks for a semantic versioning of gems'
  spec.homepage      = 'https://github.com/tf/semmy'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'git', '~> 1.3'
  spec.add_dependency 'unindent', '~> 1.0'
  spec.add_dependency 'rainbow', '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.42.0'
end
