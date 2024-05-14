module GemReport
  class Cli
    def self.run
      if ARGV.empty? || ARGV[1].nil?
        usage
        exit(1)
      end
      
      if STDIN.tty?
        usage
        exit(1)
      end

      data = STDIN.read

      inventory = Bundler::LockfileParser.new(data)
      csv_report = GemReport::Reports::CsvReport.new(ARGV[0], ARGV[1])
      csv_report.report(STDOUT, inventory)
    end

    def self.usage
      STDERR.print "\nUsage: gem_reporter [project_name] [sha]\n\n"
      STDERR.print "       Reads from STDIN by default, so make sure to provide the Gemfile.lock.\n\n"
    end
  end
end