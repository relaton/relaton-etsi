# frozen_string_literal: true

require_relative "lib/relaton_etsi/version"

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name = "relaton-etsi"
  spec.version = RelatonEtsi::VERSION
  spec.authors = ["Ribose Inc."]
  spec.email = ["open.source@ribose.com"]

  spec.summary =  "RelatonEtsi: retrieve ETSI Standards for bibliographic " \
                  "using the BibliographicItem model"
  spec.description = "RelatonEtsi: retrieve ETSI Standards for bibliographic " \
                  "using the BibliographicItem model"
  spec.homepage = "https://github.com/relaton/relaton-etsi"
  spec.license = "BSD-2-Clause"
  spec.required_ruby_version = ">= 2.7.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor
                          Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "relaton-bib", "~> 1.17.0"
  spec.add_dependency "relaton-index", "~> 0.2.7"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
