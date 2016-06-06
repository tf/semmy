module Semmy
  module Tasks
    Versioning = Struct.new(:config) do
      include Rake::DSL

      def initialize
        config ||= Configuration.new

        yield(config)

        namespace 'versioning' do
          task 'remove_development_version_suffix' do
            new_version = VersionString
              .remove_suffix(Gemspec.version, config.development_version_suffix)

            rewrite_gemspec_version(new_version)
          end

          task 'bump_minor' do
            new_version = VersionString
              .bump_minor(Gemspec.version, config.development_version_suffix)

            rewrite_gemspec_version(new_version)
          end
        end
      end

      private

      def rewrite_gemspec_version(new_version)
        Files.rewrite(VersionFile.find(Gemspec.gem_name),
                      VersionFile::Update.new(new_version))
      end
    end
  end
end
