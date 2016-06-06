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

    def previous_minor(version)
      components = version.split('.').map(&:to_i)

      if components[1] == 0
        fail(NoPreviousMinor, "Cannot get previous minor of #{version}.")
      end

      components[1] -= 1
      components.join('.')
    end

    def minor_only(version)
      version.split('.')[0..1].join('.')
    end
  end
end
