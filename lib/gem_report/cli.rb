require "bundler"
require "optparse"

module GemReport
  class Cli
    def self.run
      options = {
        format: "CSV"
      }

      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: gem_report [options] PROJECT_NAME SHA"

        opts.on("-LLOCKFILE", "--lockfile=LOCKFILE", "[Mandatory] The location of the Gemfile.lock") do |lfile|
          options[:lockfile] = lfile
        end

        opts.on("-GGEMFILE", "--gemfile=GEMFILE", "[Mandatory] The location of the Gemfile") do |gfile|
          options[:gemfile] = gfile
        end

        opts.on("-FFORMAT", "--format=FORMAT", "Format.  Supports CSV and CycloneDX") do |format|
          options[:format] = format
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end
      option_parser.parse!(ARGV)

      if ARGV.empty? || ARGV[1].nil?
        puts option_parser
        exit(1)
      end

      if !["CSV", "CycloneDX"].include?(options[:format])
        puts option_parser
        exit(1)
      end

      lock_data = File.read(options[:lockfile])
      gem_path = options[:gemfile]

      context = GemReport::ReportContext.new(lock_data, gem_path)

      case options[:format]
      when "CycloneDX"
        cyclone_report = GemReport::Reports::CycloneDxReport.new(ARGV[0], ARGV[1])
        cyclone_report.report(STDOUT, context.inventory, context.dependency_hash)
      else
        csv_report = GemReport::Reports::CsvReport.new(ARGV[0], ARGV[1])
        csv_report.report(STDOUT, context.inventory, context.dependency_hash)
      end
    end
  end
end