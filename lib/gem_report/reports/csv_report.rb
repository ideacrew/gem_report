require "csv"

module GemReport
  module Reports
    class CsvReport < Base
      def initialize(project, sha)
        @project = project
        @sha = sha
      end

      def report(stream, lockfile, gemfile_dependencies = {})
        rev_deps = reverse_dependencies(lockfile.specs)
        CSV(stream) do |csv|
          csv << [
            "project",
            "sha",
            "gem",
            "version",
            "group",
            "source",
            "source url",
            "source sha",
            "source_branch"
          ]
          lockfile.specs.each do |spec|
            csv << format_spec(spec, rev_deps, gemfile_dependencies)
          end
        end
      end

      private

      def format_spec(spec, rev_deps, gemfile_dependencies)
        [@project, @sha, spec.name, spec.version, select_gem_group(spec, rev_deps, gemfile_dependencies)] +
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
