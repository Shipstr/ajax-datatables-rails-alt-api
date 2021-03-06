
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ajax-datatables-rails/alt-api/version"

Gem::Specification.new do |spec|
  spec.name          = "ajax-datatables-rails-alt-api"
  spec.version       = AjaxDatatablesRails::AltApi::VERSION
  spec.authors       = ["Sean McCleary"]
  spec.email         = ["seanmcc@gmail.com"]

  spec.summary       = %q{This is an alternate API to ajax-datatables-rails.}
  spec.description   = <<~DESCRIPTION
    The goal of this gem is to provide a backwards compatible extension of the
    ajax-datatables-rails gem that provides an alternate API that reduces
    duplication.
  DESCRIPTION
  spec.homepage      = "https://github.com/Shipstr/#{spec.name}"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["changelog_uri"] = "https://raw.githubusercontent.com/Shipstr/#{spec.name}/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ajax-datatables-rails", "~> 1.0.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.12"
  spec.add_development_dependency "pry-byebug", "~> 3"
end
