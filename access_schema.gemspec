# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "access_schema/version"

Gem::Specification.new do |s|
  s.name        = "access_schema"
  s.version     = AccessSchema::VERSION
  s.authors     = ["Victor Gumayunov"]
  s.email       = ["gumayunov@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{AccessSchema is an ACL tool}
  s.description = %q{AccessSchema is a tool for ACL or tariff plans schema definition and checks}

  s.rubyforge_project = "access_schema"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
