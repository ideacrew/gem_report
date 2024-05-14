require "spec_helper"

describe GemReport::Reports::CsvReport, "given the enroll gemfile" do
  let(:lockfile_path) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "../../../",
        "example_data/Gemfile.lock"
      )
    )
  end

  let(:gemfile_path) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "../../../",
        "example_data/Gemfile"
      )
    )
  end

  let(:gemfile_dependencies) do
    dsl = GemReport::GemfileParser.parse(gemfile_path)
    deps = dsl.instance_eval("@dependencies")
    dep_hash = {}
    deps.each do |dep|
      dep_hash[dep.name] = dep
    end
    dep_hash
  end

  let(:lockfile) do
    Bundler::LockfileParser.new(File.read(lockfile_path))
  end

  subject { described_class.new("enroll", "trunk") }

  it "writes the report" do
    subject.report(STDERR, lockfile, gemfile_dependencies)
    STDERR.flush
  end
end