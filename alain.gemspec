# frozen_string_literal: true

require_relative "lib/alain/version"

Gem::Specification.new do |spec|
  spec.name          = 'alain'
  spec.version       = Alain::VERSION
  spec.authors       = ['Chuma Takahiro']
  spec.email         = ['co.chuma@gmail.com']

  spec.summary       = 'Code generator for rust prost'
  spec.description   = 'Code generator for rust prost'
  spec.homepage      = 'https://github.com/chumaltd/alain'
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/chumaltd/alain/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  #spec.files = Dir.chdir(File.expand_path(__dir__)) do
  #  `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  #end
  spec.files         = Dir["LICENSE", "exe/**/*", "lib/**/{*,.[a-z]*}"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "tomlrb", "~> 2.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
