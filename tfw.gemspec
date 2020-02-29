# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tfw/version'

Gem::Specification.new do |spec|
  spec.name          = 'tfw'
  spec.version       = TFW::VERSION
  spec.authors       = ['Tiago Lopo']
  spec.email         = ['tiagolopo@yahoo.com.br']

  spec.summary       = 'Terraform Wrapper using Terraform DSL for Ruby'
  spec.description   = 'Terraform Wrapper using Terraform DSL for Ruby'
  spec.homepage      = 'https://github.com/tlopo-ruby/tfw'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata['homepage_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'tfdsl', '0.1.6'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 0.79'
end
