
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "amenomi/version"

Gem::Specification.new do |spec|
  spec.name          = "amenomi"
  spec.version       = Amenomi::VERSION
  spec.authors       = ["Koda Makoto"]
  spec.email         = ["makotokoda82@gmail.com"]

  spec.summary       = %q{command line tool for managing EC2}
  spec.description   = %q{command line tool for managing EC2}
  spec.homepage      = "https://github.com/higeojisan/amenomi"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com.xxx'"
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

  spec.add_dependency 'aws-sdk-ec2', '~> 1'
  spec.add_dependency 'aws-sdk-elasticloadbalancing', '~> 1'
  spec.add_dependency 'aws-sdk-elasticloadbalancingv2', '~> 1'
  spec.add_dependency 'thor', '~> 0.20.0'
  spec.add_dependency 'terminal-table', '~> 1.8.0'
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
