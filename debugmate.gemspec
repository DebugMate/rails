require_relative "lib/debugmate/version"

Gem::Specification.new do |spec|
  spec.name        = "debugmate"
  spec.version     = Debugmate::VERSION
  spec.authors     = ["DevSquad"]
  spec.homepage    = "https://github.com/DebugMate/rails"
  spec.summary     = "Error tracking and monitoring for Ruby on Rails applications."
  spec.description = "DebugMate provides powerful error tracking and debugging tools for Rails applications."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/DebugMate/rails"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["lib/**/*.rb", "LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.4.2"

  spec.add_development_dependency "rspec-rails"
end
