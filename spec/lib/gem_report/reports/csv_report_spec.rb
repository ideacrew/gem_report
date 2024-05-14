require "spec_helper"

describe GemReport::Reports::CsvReport, "given the enroll gemfile" do
  let(:gemfile_path) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "../../../",
        "example_data/Gemfile.lock"
      )
    )
  end

  let(:lockfile) do
    Bundler::LockfileParser.new(File.read(gemfile_path))
  end

  subject { described_class.new("enroll", "trunk") }

  it "writes the report" do
    subject.report(STDERR, lockfile)
    STDERR.flush
  end
end