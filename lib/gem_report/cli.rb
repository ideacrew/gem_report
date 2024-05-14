require "bundler"
require "optparse"

module GemReport
  class Cli
    def self.run
      options = {}

      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: gem_report [options] PROJECT_NAME SHA"

        opts.on("-LLOCKFILE", "--lockfile=LOCKFILE", "[Mandatory] The location of the Gemfile.lock") do |lfile|
          options[:lockfile] = lfile
        end

        opts.on("-GGEMFILE", "--gemfile=GEMFILE", "[Mandatory] The location of the Gemfile") do |gfile|
          options[:gemfile] = gfile
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

      lock_data = File.read(options[:lockfile])
      gem_path = options[:gemfile]

      inventory = ::Bundler::LockfileParser.new(lock_data)
      csv_report = GemReport::Reports::CsvReport.new(ARGV[0], ARGV[1])
      dsl = GemReport::GemfileParser.parse(gem_path)

      deps = dsl.instance_eval("@dependencies")
      dep_hash = {}
      deps.each do |dep|
        dep_hash[dep.name] = dep
      end
      csv_report.report(STDOUT, inventory, dep_hash)
    end
  end
end