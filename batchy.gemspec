$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "batchy/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "batchy"
  s.version     = Batchy::VERSION
  s.authors     = ["Your name"]
  s.email       = ["Your email"]
  s.homepage    = ""
  s.summary     = "Summary of Batchy."
  s.description = "Description of Batchy."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13" # actually only needs action_controller and action_dispatch. Maybe will pare it down
  s.add_dependency "httparty"

  s.add_development_dependency "sqlite3"
end
