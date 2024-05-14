lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = %q{gem_report}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Trey Evans"]

  s.email = 'lewis.r.evans@gmail.com'
  s.date = %q{2024-05-01}
  s.summary = %q{Report gem versions.}
  s.description = %q{Provide a report of gem versions.}
  s.files = `git ls-files -- lib/* bin/*`.split("\n")
  s.homepage = %q{http://github.com/ideacrew/gem_report}
  s.require_paths = ["lib"]
  s.executables = ["gem_report"]
  s.license = "MIT"
  s.bindir = "bin"

  s.required_ruby_version = '>= 2.7'
  s.add_runtime_dependency "bundler"
end
