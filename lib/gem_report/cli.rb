module GemReport
  class Cli
    def self.run
      if ARGV.empty? || ARGV[1].nil?
        STDERR.print "Usage: gem_reporter [project_name] [sha]\n\n"
        exit(1)
      end
      
      data = STDIN.read


      inventory = Bundler::LockfileParser.new(data)
      csv_report = GemReport::Reports::CsvReport.new(ARGV[0], ARGV[1])
      csv_report.report(STDOUT, inventory)
    end
  end
end