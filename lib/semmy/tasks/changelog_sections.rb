module Semmy
  module Tasks
    class ChangelogSections < Base
      def define
        namespace 'changelog' do
          task 'close_section' do
            new_version = Gemspec.version
            old_version = VersionString.previous_minor(new_version)
            homepage = Gemspec.homepage

            Files.rewrite(config.changelog_path,
                          Changelog::CloseSection.new(config,
                                                     new_version: new_version,
                                                     old_version: old_version,
                                                     homepage: homepage,
                                                     date: Date.today))
          end

          task 'add_unreleased_section' do
            Files.rewrite(config.changelog_path,
                          Changlog::InsertSection.new(config))
          end
        end
      end
    end
  end
end
