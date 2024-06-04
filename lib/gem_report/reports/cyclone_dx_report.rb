require "csv"
require "json"

module GemReport
  module Reports
    class CycloneDxReport < Base
      def initialize(project, sha, mute_non_production = false)
        @project = project
        @sha = sha
        @mute_exclusions = mute_non_production
      end

      def report(stream, lockfile, gemfile_dependencies = {})
        rev_deps = reverse_dependencies(lockfile.specs)
        project_bom_ref = @project + "-" + @sha
        json_output = {
          "bomFormat" => "CycloneDX",
          "specVersion" => "1.5",
          "metadata" => {
            "component" => {
              "type" => "application",
              "name" => @project,
              "bom-ref" => project_bom_ref,
              "hashes" => [
                {
                  "alg" => "SHA-1",
                  "content" => @sha
                }
              ]
            }
          }
        }
        components = lockfile.specs.inject({:components => [], :dependencies => []}) do |acc, spec|
          result = format_spec(spec, rev_deps, gemfile_dependencies)
          if result[:omit]
            acc
          else
            {
              components: acc[:components] + [result[:component]],
              dependencies: acc[:dependencies] + [result[:dependency]]
            }
          end
        end
        stream.puts(
          JSON.generate(
            json_output.merge({
              components: components[:components],
              dependencies: [
                {
                  ref: project_bom_ref,
                  dependsOn: components[:dependencies]
                }
              ]
            })
          )
        )
      end

      private 

      def format_spec(spec, rev_deps, gemfile_dependencies)
        scope = case select_gem_group(spec, rev_deps, gemfile_dependencies)
                when "development"
                  "optional"
                when "test"
                  "excluded"
                else
                  "required"
                end

        bom_ref = spec.name + "-" + spec.version.to_s
        component_hash = {
          "type" => "library",
          "bom-ref" => bom_ref,
          "name" => spec.name,
          "version" => spec.version,
          "scope" => scope,
        }
        omit = @mute_exclusions && (scope != "required")
        {
          component: component_hash.merge(format_source(spec)),
          dependency: bom_ref,
          omit: omit
        }
      end

      def format_source(spec)
        case spec.source
        when Bundler::Source::Rubygems
          {
            "cpe" => "cpe:/a:rubygems:#{spec.name}:#{spec.version.to_s}",
            "purl" => "pkg:gem/#{spec.name}@#{spec.version.to_s}"
          }
        when Bundler::Source::Git
          # git_branch = get_git_branch(spec.source)
          {
            "externalReferences" => [
              {
                "url" => spec.source.uri,
                "type" => "vcs",
                "hashes" => [
                  {
                    "alg" => "SHA-1",
                    "content" => spec.source.revision
                  }
                ]
              }
            ]
          }
        when Bundler::Source::Path
          {
            "hashes" => [
              {
                "alg" => "SHA-1",
                "content" => @sha
              }
            ]
          }
          # ["path", spec.source.path, @sha ]
        else
          raise spec.source.inspect
        end
      end
    end
  end
end