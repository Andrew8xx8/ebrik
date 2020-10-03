require_relative 'lib/ebrik/version'

Gem::Specification.new do |spec|
  spec.name          = "ebrik"
  spec.version       = Ebrik::VERSION
  spec.authors       = ["Andrew Kulakov"]
  spec.email         = ["avk@8xx8.ru"]

  spec.summary       = "Ebrik Server"
  spec.description   = "Simple Multi-thread Web Server"
  spec.homepage      = "https://github.com/Andrew8xx8/ebrik"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Andrew8xx8/ebrik"
  spec.metadata["changelog_uri"] = "https://github.com/Andrew8xx8/ebrik"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rack"
end
