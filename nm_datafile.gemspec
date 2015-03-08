# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nm_datafile/version'

Gem::Specification.new do |spec|
  spec.name          = "nm_datafile"
  spec.version       = NmDatafile::VERSION
  spec.authors       = ["antisec"]
  spec.email         = ["antisec@antisec.com"]
  spec.summary       = %q{A gem that saves files into a secure encrypted file.}
  spec.description   = %q{A gem that creates a data file based on arrays or strings that you feed it.  When you save the file, you can choose from multiple encryption methods, asymetric, symetric, etc. etc.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
end
