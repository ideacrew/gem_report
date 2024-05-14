require "csv"

module GemReport
  module Reports
    class CsvReport
      def initialize(project, sha)
        @project = project
        @sha = sha
      end

      def report(stream, lockfile)
        CSV(stream) do |csv|
          csv << [
            "project",
            "sha",
            "gem",
            "version",
            "source",
            "source url",
            "source sha",
            "source_branch"
          ]
          lockfile.specs.each do |spec|
            csv << format_spec(spec)
          end
        end
      end

      def format_spec(spec)
        [@project, @sha, spec.name, spec.version] +
          format_source(spec)
      end

      def format_source(spec)
        case spec.source
        when Bundler::Source::Rubygems
          ["rubygems", spec.source.remotes.map(&:to_s).join(", ")]
        when Bundler::Source::Git
          ["git", spec.source.uri, spec.source.revision, get_git_branch(spec.source)]
        when Bundler::Source::Path
          ["path", spec.source.path, @sha ]
        else
          raise spec.source.inspect
        end
      end

      def get_git_branch(source)
        source.options["ref"] || source.ref
      end
    end
  end
end
