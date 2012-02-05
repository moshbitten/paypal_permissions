# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "paypal_permissions/version"

Gem::Specification.new do |s|
  s.name        = "paypal_permissions"
  s.version     = PaypalPermissions::VERSION
  s.authors     = ["Mark Paine"]
  s.email       = ["mark@mailbiter.com"]
  s.homepage    = ""
  s.summary     = %q{"Write a gem summary"}
  s.description = %q{"Write a gem description"}

  s.rubyforge_project = "paypal_permissions"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "activesupport", "~> 3.0"
  s.add_development_dependency "activemerchant"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "aruba"
  s.add_runtime_dependency "activesupport", "~> 3.0"
  s.add_runtime_dependency "activemerchant"
  s.add_runtime_dependency "thor"
end
