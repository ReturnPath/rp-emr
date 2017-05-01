# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rp/emr/version'

Gem::Specification.new do |spec|
  spec.name          = "rp-emr"
  spec.version       = RP::EMR::VERSION
  spec.authors       = ["Ryan Michael", "Andrew Harrison"]
  spec.email         = ["ryanmichael@otherinbox.com", 'andrew.harrison@returnpath.com']
  spec.summary       = %q{EMR Helpers}
  spec.description   = %q{Framework for launching EMR job flows}
  spec.homepage      = "https://github.com/ReturnPath/rp-emr"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "aws-sdk", "~> 2.0"
  spec.add_dependency "assembler"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "fuubar"
end
