# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'morpher_inflecter/version'

Gem::Specification.new do |gem|
  gem.name          = "morpher_inflecter"
  gem.version       = MorpherInflecter::VERSION
  gem.authors       = ["Dmitry Penkin"]
  gem.homepage      = "http://github.com/dmitryp/morpher_inflecter/"
  gem.summary       = "Morpher.ru webservice client (Russian language inflection)"
  gem.description   = "Morpher.ru inflections for russian proper and common nouns. Code inspired by yandex_inflect gem by Yaroslav Markin."
  gem.rubyforge_project = "morpher_inflecter"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.license = 'MIT'
  gem.require_paths = ["lib"]

  gem.has_rdoc = true
  gem.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]

  gem.add_dependency "nokogiri"
  gem.add_development_dependency "rspec", '2.6'
  gem.add_development_dependency "rake"
end
