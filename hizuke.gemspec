# frozen_string_literal: true

require_relative 'lib/hizuke/version'

Gem::Specification.new do |spec|
  spec.name = 'hizuke'
  spec.version = Hizuke::VERSION
  spec.authors = ['Juraj Maťaše']
  spec.email = ['juraj@hey.com']

  spec.summary = 'A simple date parser for natural language time references'
  spec.description = 'Hizuke is a lightweight utility that extracts dates from text ' \
                     'by recognizing common time expressions. ' \
                     'It cleans the original text and returns both the parsed date ' \
                     'and the text without the date reference.'
  spec.homepage = 'https://github.com/majur/hizuke'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Add development dependencies here
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'
end
