require "spec_helper"

describe GemReport::Reports::CycloneDxReport, "given the enroll gemfile" do
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

  let(:report_context) do
    GemReport::ReportContext.new(
      File.read(lockfile_path),
      gemfile_path
    )
  end

  subject { described_class.new("enroll", "trunk") }

  it "writes the report" do
    subject.report(STDERR, report_context.inventory, report_context.dependency_hash)
    STDERR.flush
  end
end