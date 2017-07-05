# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "puppet/debugger/playbooks/version"

Gem::Specification.new do |spec|
  spec.name          = "puppet-debugger-playbooks"
  spec.version       = "0.1.0"
  spec.authors       = ["Corey Osman"]
  spec.email         = ["corey@nwops.io"]

  spec.summary       = %q{A puppet debugger plugin that allows one to play back predfined puppet scripts.}
  spec.description   = %q{A puppet debugger plugin that allows one to play back predfined puppet scripts.}
  spec.homepage      = "https://github.com/nwops/puppet-debugger-playbooks"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
