module GemReport
  module Reports
    class Base
      def select_gem_group(spec, rev_deps, gemfile_dependencies)
        return derive_group(spec, rev_deps, gemfile_dependencies) unless gemfile_dependencies.has_key?(spec.name)
        groups = gemfile_dependencies[spec.name].groups
        choose_group(groups)
      end

      def choose_group(groups)
        return "production" if groups.include?(:default) || groups.include?(:production)
        return "development" if groups.include?(:development)
        "test"
      end

      def derive_group(spec, rev_deps, gemfile_dependencies)
        required_because_of = rev_deps[spec.name]
        return "derived" if required_because_of.empty?
        toplevels, intermediates = required_because_of.partition { |r| gemfile_dependencies.has_key?(r) }
        clear_intermediates = intermediates.flat_map do |inter|
          shrink_intermediate(inter, rev_deps, gemfile_dependencies)
        end
        all_toplevels = (toplevels + clear_intermediates).uniq
        all_groups = all_toplevels.flat_map { |tl| gemfile_dependencies.has_key?(tl) ? gemfile_dependencies[tl].groups : [] }.uniq
        choose_group(all_groups)
      end

      def shrink_intermediate(intermediate, rev_deps, gemfile_dependencies)
        required_because_of = rev_deps[intermediate]
        return [] if required_because_of.empty?
        toplevels, intermediates = required_because_of.partition { |r| gemfile_dependencies.has_key?(r) }
        clear_intermediates = intermediates.flat_map do |inter|
          shrink_intermediate(inter, rev_deps, gemfile_dependencies)
        end
        (toplevels + clear_intermediates).uniq
      end

      def reverse_dependencies(specs)
        rev_deps = Hash.new { |h, k| h[k] = Array.new }
        specs.each do |spec|
          spec.dependencies.each do |dep|
            rev_deps[dep.name] = (rev_deps[dep.name] + [spec.name]).uniq
          end
        end
        rev_deps
      end
    end
  end
end