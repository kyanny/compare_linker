# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'compare_linker/version'

Gem::Specification.new do |spec|
  spec.name          = "compare_linker"
  spec.version       = CompareLinker::VERSION
  spec.authors       = ["Kensuke Nagae"]
  spec.email         = ["kyanny@gmail.com"]
  spec.description   = %q{Create GitHub's compare view URLs for pull request from diff of Gemfile.lock}
  spec.summary       = %q{Create GitHub's compare view URLs for pull request}
  spec.homepage      = "https://github.com/kyanny/compare_linker"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "octokit"
  spec.add_dependency "httpclient"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
