require_relative "lib/debugmate/version"

Gem::Specification.new do |spec|
  spec.name        = "debugmate"
  spec.version     = Debugmate::VERSION
  spec.authors     = ["Eduardo Barijan"]
  spec.email       = ["eduardo.barijan@devsquad.com"]
  spec.homepage    = "http://127.0.0.1"
  spec.summary     = "Summary of DebugMate."
  spec.description = "Description of DebugMate."
    spec.license     = "MIT"
  
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://127.0.0.1"
  spec.metadata["changelog_uri"] = "http://127.0.0.1"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.4.2"
  spec.add_dependency "rspec-rails"
end
