require "bundler"

module GemReport
  class ReportContext
    attr_reader :inventory, :dependency_hash

    def initialize(lockfile_data, gemfile_path)
      @inventory = ::Bundler::LockfileParser.new(lockfile_data)
      @dependency_hash = build_dependency_hash(gemfile_path)
    end

    private

    def build_dependency_hash(gemfile_path)
      dsl = GemReport::GemfileParser.parse(gemfile_path)

      deps = dsl.instance_eval("@dependencies")
      dep_hash = {}
      deps.each do |dep|
        dep_hash[dep.name] = dep
      end
      dep_hash
    end
  end
end