module Semmy
  module VersionString
    extend self

    class SuffixNotFound < Error; end

    class UnexpectedSuffix < Error; end

    class NoPreviousMinor < Error; end

    def remove_suffix(version, suffix)
      new_version = version.dup

      unless new_version.gsub!(/.#{suffix}$/, '')
        fail(SuffixNotFound, "Suffix #{suffix} not found in #{version}")
      end

      new_version
    end

    def bump_minor(version, suffix)
      components = version.split('.')

      unless components.last =~ /^[0-9]+$/
        fail(UnexpectedSuffix, "Expected a version without suffix, found #{version}.")
      end

      components.map!(&:to_i)
      components[1] += 1
      components << suffix

      components.join('.')
    end

    def minor_only(version)
      version.split('.')[0..1].join('.')
    end

    def components(version)
      components = version.split('.')

      {
        major: components[0],
        minor: components[1],
        patch: components[2]
      }
    end

    def previous_version(version)
      components = version.split('.').map(&:to_i)

      if components[2] > 0
        components[2] -= 1
      elsif components[1] > 0
        components[1] -= 1
      else
        fail(NoPreviousMinor, "Cannot get previous version of #{version}.")
      end

      components.join('.')
    end

    def previous_stable_branch_name(version, stable_branch_name_pattern)
      stable_branch_name_pattern % previous_minor_version_components(version)
    end

    private

    def previous_minor_version_components(version)
      components = version.split('.').map(&:to_i)

      if components[1].zero?
        fail(NoPreviousMinor, "Cannot get previous minor version of #{version}.")
      end

      {
        major: components[0],
        minor: components[1] - 1
      }
    end
  end
end
